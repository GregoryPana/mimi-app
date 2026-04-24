import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/sanity_repository.dart';
import '../theme.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/pastel_card.dart';
import '../widgets/skeleton_loader.dart';

import '../../app/providers.dart';

class SharedHubScreen extends ConsumerStatefulWidget {
  const SharedHubScreen({super.key});

  @override
  ConsumerState<SharedHubScreen> createState() => _SharedHubScreenState();
}

class _SharedHubScreenState extends ConsumerState<SharedHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        child: Column(
          children: [
            // Custom Header area for Tabs
            Container(
              padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 80, 20, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      indicatorColor: AppColors.pastelPink,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelColor: AppColors.pastelPink,
                      unselectedLabelColor: AppColors.textSecondary,
                      dividerColor: Colors.transparent,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                      tabs: const [
                        Tab(text: 'Photos'),
                        Tab(text: 'Notes'),
                        Tab(text: 'Watch'),
                      ],
                    ),
                  ),
                  _AuthorChip(onTap: () => _showAuthorPicker(context)),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ImagesTab(tabController: _tabController),
                  _NotesTab(tabController: _tabController),
                  _WatchlistTab(tabController: _tabController),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          final labels = ['Add Photo', 'Add Note', 'Add Movie'];
          final icons = [LucideIcons.imagePlus, LucideIcons.pencil, LucideIcons.plus];
          final idx = _tabController.index;
          return FloatingActionButton.extended(
            onPressed: () => _onFabTapped(context, idx),
            backgroundColor: AppColors.pastelPink,
            foregroundColor: Colors.white,
            icon: Icon(icons[idx]),
            label: Text(labels[idx]),
          );
        },
      ),
    );
  }

  void _onFabTapped(BuildContext context, int tabIndex) {
    HapticFeedback.lightImpact();
    switch (tabIndex) {
      case 0:
        _showAddImageSheet(context);
      case 1:
        _showAddNoteSheet(context);
      case 2:
        _showAddMovieSheet(context);
    }
  }

  void _showAuthorPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) {
          final authorAsync = ref.watch(authorProvider);
          final author = authorAsync.value ?? 'Mimi Boy';
          return PastelCard(
            margin: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                _BottomSheetHandle(),
                const SizedBox(height: 20),
                Text('Who are you?',
                    style: Theme.of(ctx).textTheme.titleSmall),
                const SizedBox(height: 16),
                Row(
                  children: ['Mimi Boy', 'Mimi Girl'].map((name) {
                    final selected = author == name;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: _ChoiceButton(
                          label: name,
                          selected: selected,
                          onTap: () {
                            ref.read(authorProvider.notifier).setAuthor(name);
                            Navigator.pop(ctx);
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddImageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddImageSheet(
        onSubmit: (file, caption) async {
          Navigator.pop(ctx);
          final author = ref.read(authorProvider).value ?? 'Mimi Boy';
          try {
            _showLoadingSnack(context, 'Uploading photo...');
            final repo = ref.read(sanityRepositoryProvider);
            final assetId = await repo.uploadImageAsset(file);
            await repo.createSharedImage(
              assetId: assetId,
              caption: caption,
              uploadedBy: author,
            );
            ref.invalidate(sharedImagesProvider);
            if (context.mounted) _showSuccessSnack(context, 'Photo shared!');
          } catch (e) {
            if (context.mounted) _showErrorSnack(context, 'Upload failed: $e');
          }
        },
      ),
    );
  }

  void _showAddNoteSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddNoteSheet(
        author: ref.read(authorProvider).value ?? 'Mimi Boy',
        onSubmit: (title, content) async {
          Navigator.pop(ctx);
          final author = ref.read(authorProvider).value ?? 'Mimi Boy';
          try {
            await ref.read(sanityRepositoryProvider).createNote(
              title: title,
              content: content,
              author: author,
            );
            ref.invalidate(sharedNotesProvider);
            if (context.mounted) _showSuccessSnack(context, 'Note shared!');
          } catch (e) {
            if (context.mounted) _showErrorSnack(context, 'Error: $e');
          }
        },
      ),
    );
  }

  void _showAddMovieSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddMovieSheet(
        author: ref.read(authorProvider).value ?? 'Mimi Boy',
        onSubmit: (title) async {
          Navigator.pop(ctx);
          final author = ref.read(authorProvider).value ?? 'Mimi Boy';
          try {
            await ref.read(sanityRepositoryProvider).addMovie(
              title: title,
              addedBy: author,
            );
            ref.invalidate(watchlistProvider);
            if (context.mounted) _showSuccessSnack(context, 'Added to watchlist!');
          } catch (e) {
            if (context.mounted) _showErrorSnack(context, 'Error: $e');
          }
        },
      ),
    );
  }

  void _showLoadingSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Row(children: [
          const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
          const SizedBox(width: 12),
          Text(message),
        ]),
        duration: const Duration(seconds: 30),
        backgroundColor: AppColors.textPrimary,
      ));
  }

  void _showSuccessSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: AppColors.pastelMint,
        duration: const Duration(seconds: 2),
      ));
  }

  void _showErrorSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 4),
      ));
  }
}

// ── Author chip in AppBar ──────────────────────────────────────────────────────

class _AuthorChip extends ConsumerWidget {
  const _AuthorChip({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authorAsync = ref.watch(authorProvider);
    final author = authorAsync.value ?? 'Mimi Boy';
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.pastelPink.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.user, size: 14, color: AppColors.pastelPink),
              const SizedBox(width: 6),
              Text(author,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.pastelPink,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Images Tab ────────────────────────────────────────────────────────────────

class _ImagesTab extends ConsumerWidget {
  const _ImagesTab({required this.tabController});
  final TabController tabController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagesAsync = ref.watch(sharedImagesProvider);
    const topPad = 12.0;

    return RefreshIndicator(
      color: AppColors.pastelPink,
      onRefresh: () => ref.refresh(sharedImagesProvider.future),
      child: imagesAsync.when(
        data: (images) => images.isEmpty
            ? _EmptyState(
                icon: LucideIcons.imagePlus,
                message: 'No shared photos yet',
                sub: 'Tap + to share your first moment',
              )
            : ListView.builder(
                padding: EdgeInsets.fromLTRB(20, topPad, 20, 100),
                itemCount: images.length,
                itemBuilder: (context, index) => _SharedImageCard(
                  data: images[index],
                  onDelete: () async {
                    await ref.read(sanityRepositoryProvider).deleteDocument(images[index]['_id'] as String);
                    ref.invalidate(sharedImagesProvider);
                  },
                ).animate().fadeIn(duration: 400.ms, delay: (index * 40).ms).slideY(begin: 0.05, end: 0),
              ),
        loading: () => ListView(
          padding: EdgeInsets.fromLTRB(20, topPad, 20, 24),
          children: List.generate(3, (i) => const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: SkeletonLoader(height: 280),
          )),
        ),
        error: (err, _) => _ErrorState(error: err.toString()),
      ),
    );
  }
}

class _SharedImageCard extends StatelessWidget {
  const _SharedImageCard({required this.data, required this.onDelete});
  final dynamic data;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final imageUrl = data['imageUrl'] as String?;
    final caption = data['caption'] as String? ?? '';
    final uploadedBy = data['uploadedBy'] as String? ?? '';
    final ts = data['timestamp'] as String?;
    final date = ts != null ? _formatDate(DateTime.tryParse(ts)) : 'Recently';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: PastelCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      height: 240,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        height: 240,
                        color: AppColors.pastelPeach.withValues(alpha: 0.08),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        height: 240,
                        color: AppColors.pastelPeach.withValues(alpha: 0.08),
                        child: const Center(
                          child: Icon(LucideIcons.imageOff, color: AppColors.pastelPeach),
                        ),
                      ),
                    )
                  : Container(
                      height: 240,
                      color: AppColors.pastelPeach.withValues(alpha: 0.08),
                      child: const Center(
                        child: Icon(LucideIcons.image, size: 40, color: AppColors.pastelPeach),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (caption.isNotEmpty)
                          Text(caption, style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 4),
                        Text(
                          'Shared by $uploadedBy • $date',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(LucideIcons.trash2, size: 18),
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Recently';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ── Notes Tab ─────────────────────────────────────────────────────────────────

class _NotesTab extends ConsumerWidget {
  const _NotesTab({required this.tabController});
  final TabController tabController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(sharedNotesProvider);
    const topPad = 12.0;

    return RefreshIndicator(
      color: AppColors.pastelPink,
      onRefresh: () => ref.refresh(sharedNotesProvider.future),
      child: notesAsync.when(
        data: (notes) => notes.isEmpty
            ? _EmptyState(
                icon: LucideIcons.pencil,
                message: 'No notes yet',
                sub: 'Leave a thought for each other',
              )
            : ListView.builder(
                padding: EdgeInsets.fromLTRB(20, topPad, 20, 100),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return _NoteCard(
                    note: note,
                    onDelete: () async {
                      await ref.read(sanityRepositoryProvider).deleteDocument(note['_id'] as String);
                      ref.invalidate(sharedNotesProvider);
                    },
                  ).animate().fadeIn(duration: 400.ms, delay: (index * 40).ms).slideY(begin: 0.05, end: 0);
                },
              ),
        loading: () => ListView(
          padding: EdgeInsets.fromLTRB(20, topPad, 20, 24),
          children: List.generate(3, (i) => const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: SkeletonLoader(height: 120),
          )),
        ),
        error: (err, _) => _ErrorState(error: err.toString()),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note, required this.onDelete});
  final dynamic note;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final author = note['author'] as String? ?? 'Unknown';
    final isMimiBoy = author == 'Mimi Boy';
    final accentColor = isMimiBoy ? AppColors.pastelBlue : AppColors.pastelPink;
    final ts = note['date'] as String?;
    final date = ts != null ? _formatDate(DateTime.tryParse(ts)) : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: PastelCard(
        padding: EdgeInsets.zero,
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(22)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              author,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: accentColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (date.isNotEmpty)
                            Text(date, style: Theme.of(context).textTheme.bodySmall),
                          IconButton(
                            onPressed: onDelete,
                            icon: const Icon(LucideIcons.trash2, size: 16),
                            color: AppColors.textMuted,
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if ((note['title'] as String? ?? '').isNotEmpty) ...[
                        Text(note['title'] as String,
                            style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 6),
                      ],
                      Text(note['content'] as String? ?? '',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}';
  }
}

// ── Watchlist Tab ─────────────────────────────────────────────────────────────

class _WatchlistTab extends ConsumerWidget {
  const _WatchlistTab({required this.tabController});
  final TabController tabController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlistAsync = ref.watch(watchlistProvider);
    const topPad = 12.0;

    return RefreshIndicator(
      color: AppColors.pastelPink,
      onRefresh: () => ref.refresh(watchlistProvider.future),
      child: watchlistAsync.when(
        data: (movies) {
          final unwatched = movies.where((m) => !(m['isWatched'] as bool? ?? false)).toList();
          final watched = movies.where((m) => m['isWatched'] as bool? ?? false).toList();

          return ListView(
            padding: EdgeInsets.fromLTRB(20, topPad, 20, 100),
            children: [
              if (movies.isEmpty)
                _EmptyState(
                  icon: LucideIcons.popcorn,
                  message: 'Nothing to watch yet',
                  sub: 'Add a movie or show to watch together',
                ),
              if (unwatched.isNotEmpty) ...[
                _SectionLabel(label: 'To Watch (${unwatched.length})'),
                const SizedBox(height: 8),
                ...unwatched.asMap().entries.map((e) => _MovieCard(
                  movie: e.value,
                  onToggle: () async {
                    await ref.read(sanityRepositoryProvider)
                        .setWatched(e.value['_id'] as String, true);
                    ref.invalidate(watchlistProvider);
                  },
                  onDelete: () async {
                    await ref.read(sanityRepositoryProvider)
                        .deleteDocument(e.value['_id'] as String);
                    ref.invalidate(watchlistProvider);
                  },
                ).animate().fadeIn(duration: 400.ms, delay: (e.key * 40).ms)),
              ],
              if (watched.isNotEmpty) ...[
                const SizedBox(height: 16),
                _SectionLabel(label: 'Watched (${watched.length})'),
                const SizedBox(height: 8),
                ...watched.asMap().entries.map((e) => _MovieCard(
                  movie: e.value,
                  onToggle: () async {
                    await ref.read(sanityRepositoryProvider)
                        .setWatched(e.value['_id'] as String, false);
                    ref.invalidate(watchlistProvider);
                  },
                  onDelete: () async {
                    await ref.read(sanityRepositoryProvider)
                        .deleteDocument(e.value['_id'] as String);
                    ref.invalidate(watchlistProvider);
                  },
                ).animate().fadeIn(duration: 400.ms, delay: (e.key * 40).ms)),
              ],
            ],
          );
        },
        loading: () => ListView(
          padding: EdgeInsets.fromLTRB(20, topPad, 20, 24),
          children: List.generate(4, (i) => const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: SkeletonLoader(height: 76),
          )),
        ),
        error: (err, _) => _ErrorState(error: err.toString()),
      ),
    );
  }
}

class _MovieCard extends StatelessWidget {
  const _MovieCard({
    required this.movie,
    required this.onToggle,
    required this.onDelete,
  });

  final dynamic movie;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isWatched = movie['isWatched'] as bool? ?? false;
    final rating = (movie['rating'] as num?)?.toInt() ?? 0;
    final addedBy = movie['addedBy'] as String? ?? '';
    final accentColor = isWatched ? AppColors.pastelMint : AppColors.pastelLavender;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PastelCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isWatched
                      ? AppColors.pastelMint.withValues(alpha: 0.15)
                      : AppColors.pastelLavender.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isWatched ? LucideIcons.checkCircle2 : LucideIcons.circle,
                  size: 22,
                  color: accentColor,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie['title'] as String? ?? 'Untitled',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      decoration: isWatched ? TextDecoration.lineThrough : null,
                      color: isWatched ? AppColors.textMuted : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (addedBy.isNotEmpty) ...[
                        Text(
                          'by $addedBy',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (isWatched && rating > 0)
                        Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              Icons.star_rounded,
                              size: 12,
                              color: i < rating ? Colors.amber : Colors.grey.shade300,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(LucideIcons.trash2, size: 16),
              color: AppColors.textMuted,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom Sheet Widgets ───────────────────────────────────────────────────────

class _AddImageSheet extends StatefulWidget {
  const _AddImageSheet({required this.onSubmit});
  final Future<void> Function(File file, String caption) onSubmit;

  @override
  State<_AddImageSheet> createState() => _AddImageSheetState();
}

class _AddImageSheetState extends State<_AddImageSheet> {
  File? _pickedFile;
  final _captionCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) setState(() => _pickedFile = File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: PastelCard(
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            _BottomSheetHandle(),
            const SizedBox(height: 16),
            Text('Share a Photo',
                style: Theme.of(context).textTheme.titleSmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.pastelPeach.withValues(alpha: 0.08),
                  border: Border.all(
                    color: _pickedFile != null
                        ? AppColors.pastelPink
                        : AppColors.border,
                    width: 1.5,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: _pickedFile != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(_pickedFile!, fit: BoxFit.cover),
                          Positioned(
                            top: 8, right: 8,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                                ),
                                child: const Icon(LucideIcons.pencil, size: 14),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.imagePlus, size: 32, color: AppColors.pastelPeach),
                          const SizedBox(height: 8),
                          Text('Tap to choose a photo',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            _SheetTextField(
              controller: _captionCtrl,
              hint: 'Caption (optional)',
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            _SubmitButton(
              label: 'Share Photo',
              loading: _loading,
              enabled: _pickedFile != null,
              onTap: () async {
                if (_pickedFile == null) return;
                setState(() => _loading = true);
                await widget.onSubmit(_pickedFile!, _captionCtrl.text.trim());
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _AddNoteSheet extends StatefulWidget {
  const _AddNoteSheet({required this.author, required this.onSubmit});
  final String author;
  final Future<void> Function(String title, String content) onSubmit;

  @override
  State<_AddNoteSheet> createState() => _AddNoteSheetState();
}

class _AddNoteSheetState extends State<_AddNoteSheet> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: PastelCard(
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            _BottomSheetHandle(),
            const SizedBox(height: 16),
            Text('A note from ${widget.author}',
                style: Theme.of(context).textTheme.titleSmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            _SheetTextField(controller: _titleCtrl, hint: 'Title'),
            const SizedBox(height: 12),
            _SheetTextField(
              controller: _contentCtrl,
              hint: 'Write something beautiful...',
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            _SubmitButton(
              label: 'Share Note',
              loading: _loading,
              enabled: _contentCtrl.text.isNotEmpty,
              onTap: () async {
                final content = _contentCtrl.text.trim();
                if (content.isEmpty) return;
                setState(() => _loading = true);
                await widget.onSubmit(_titleCtrl.text.trim(), content);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _AddMovieSheet extends StatefulWidget {
  const _AddMovieSheet({required this.author, required this.onSubmit});
  final String author;
  final Future<void> Function(String title) onSubmit;

  @override
  State<_AddMovieSheet> createState() => _AddMovieSheetState();
}

class _AddMovieSheetState extends State<_AddMovieSheet> {
  final _titleCtrl = TextEditingController();
  bool _loading = false;

  @override
  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: PastelCard(
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            _BottomSheetHandle(),
            const SizedBox(height: 16),
            Text('Add to Watchlist',
                style: Theme.of(context).textTheme.titleSmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Added by ${widget.author}',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            _SheetTextField(
              controller: _titleCtrl,
              hint: 'Movie or show title',
              autofocus: true,
            ),
            const SizedBox(height: 20),
            _SubmitButton(
              label: 'Add to List',
              loading: _loading,
              enabled: _titleCtrl.text.isNotEmpty,
              onTap: () async {
                final title = _titleCtrl.text.trim();
                if (title.isEmpty) return;
                setState(() => _loading = true);
                await widget.onSubmit(title);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Shared UI Primitives ──────────────────────────────────────────────────────

class _BottomSheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _SheetTextField extends StatefulWidget {
  const _SheetTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final bool autofocus;

  @override
  State<_SheetTextField> createState() => _SheetTextFieldState();
}

class _SheetTextFieldState extends State<_SheetTextField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      maxLines: widget.maxLines,
      autofocus: widget.autofocus,
      decoration: InputDecoration(
        hintText: widget.hint,
        filled: true,
        fillColor: AppColors.appBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.pastelPink, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.label,
    required this.onTap,
    required this.loading,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onTap;
  final bool loading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (enabled && !loading) ? onTap : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.pastelPink,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.disabled,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
          : Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.pastelPink : AppColors.appBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.pastelPink : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.message,
    required this.sub,
  });

  final IconData icon;
  final String message;
  final String sub;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top + kToolbarHeight + 52;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - topPad - 100,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.pastelPink.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 36, color: AppColors.pastelPink.withValues(alpha: 0.4)),
              ),
              const SizedBox(height: 16),
              Text(message, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Text(sub, style: Theme.of(context).textTheme.bodySmall),
            ],
          ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.96, 0.96)),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.wifiOff, size: 40, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text('Could not connect',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 8),
            Text('Pull to refresh', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: AppColors.textMuted,
        letterSpacing: 1.2,
      ),
    );
  }
}
