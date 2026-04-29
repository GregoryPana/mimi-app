import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../app/providers.dart';
import '../../core/constants/app_config.dart';
import '../../data/sanity_repository.dart';
import '../../domain/entities.dart';
import '../theme.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/pastel_card.dart';
import '../widgets/sanity_error_state.dart';
import '../widgets/skeleton_loader.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key});

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

enum GalleryTab { ours, yours, shared }

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  String _selectedFolder = 'seychelles';
  GalleryTab _currentTab = GalleryTab.ours;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      ref
          .read(progressControllerProvider.notifier)
          .updateLastGalleryFolder(
            AppConfig.galleryFolders[_selectedFolder] ?? _selectedFolder,
          );

      final shouldShow = await ref
          .read(progressControllerProvider.notifier)
          .showGalleryIntroIfNeeded();
      if (!mounted || !shouldShow) return;
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text('For you, Mimi 💕'),
            content: const Text(
              'I know you don\'t like all of these pics but they make up our essence, '
              'and have a lot of meaning to me... some are just what I could find of us together alone. '
              'Anyways I hope you enjoy, Mimi!',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Okay, my love'),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final contentAsync = ref.watch(contentProvider);
    final userCollectionsAsync = ref.watch(userGalleryControllerProvider);

    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('Memories'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  _TabButton(
                    label: 'Ours',
                    isSelected: _currentTab == GalleryTab.ours,
                    onTap: () => setState(() => _currentTab = GalleryTab.ours),
                  ),
                  const SizedBox(width: 8),
                  _TabButton(
                    label: 'Yours',
                    isSelected: _currentTab == GalleryTab.yours,
                    onTap: () => setState(() => _currentTab = GalleryTab.yours),
                  ),
                  const SizedBox(width: 8),
                  _TabButton(
                    label: 'Shared',
                    isSelected: _currentTab == GalleryTab.shared,
                    onTap: () =>
                        setState(() => _currentTab = GalleryTab.shared),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            MediaQuery.of(context).padding.top + kToolbarHeight + 62,
            20,
            12,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _currentTab == GalleryTab.ours
                ? contentAsync.when(
                    data: (content) {
                      final filtered = content.gallery
                          .where(
                            (item) =>
                                item.imageAsset.contains('/$_selectedFolder/'),
                          )
                          .toList();
                      final viewedIds =
                          ref
                              .watch(progressControllerProvider)
                              .value
                              ?.galleryViewedIds ??
                          <String>{};
                      return Column(
                        children: [
                          _FolderSwitcher(
                            selected: _selectedFolder,
                            onChanged: (value) {
                              setState(() => _selectedFolder = value);
                              ref
                                  .read(progressControllerProvider.notifier)
                                  .updateLastGalleryFolder(
                                    AppConfig.galleryFolders[value] ?? value,
                                  );
                            },
                          ),
                          const SizedBox(height: 14),
                          Expanded(
                            child: _OurGalleryGrid(
                              filtered: filtered,
                              viewedIds: viewedIds,
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => Column(
                      children: [
                        const SkeletonLoader(height: 50),
                        const SizedBox(height: 14),
                        Expanded(
                          child: GridView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: 6,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 14,
                                  crossAxisSpacing: 14,
                                  childAspectRatio: 0.9,
                                ),
                            itemBuilder: (context, index) =>
                                const SkeletonLoader(),
                          ),
                        ),
                      ],
                    ),
                    error: (error, _) => SanityErrorState(
                      title: 'Could not load memories right now',
                      error: error,
                      onRetry: () => ref.invalidate(contentProvider),
                    ),
                  )
                : _currentTab == GalleryTab.yours
                ? userCollectionsAsync.when(
                    data: (collections) =>
                        _UserCollectionsView(collections: collections),
                    loading: () => Column(
                      children: [
                        const SkeletonLoader(height: 70),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: 4,
                            itemBuilder: (_, i) => const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: SkeletonLoader(height: 80),
                            ),
                          ),
                        ),
                      ],
                    ),
                    error: (error, _) => SanityErrorState(
                      title: 'Could not load your collections',
                      error: error,
                      onRetry: () =>
                          ref.invalidate(userGalleryControllerProvider),
                    ),
                  )
                : ref
                      .watch(sharedCollectionsProvider)
                      .when(
                        data: (cols) =>
                            _SharedCollectionsView(collections: cols),
                        loading: () => const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.pastelPink,
                          ),
                        ),
                        error: (e, _) => SanityErrorState(
                          title: 'Could not load shared collections',
                          error: e,
                          onRetry: () =>
                              ref.invalidate(sharedCollectionsProvider),
                        ),
                      ),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const activeColor = AppColors.pastelPink;
    const inactiveTextColor = AppColors.textPrimary;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? activeColor.withValues(alpha: 0.38)
                : Colors.white.withValues(alpha: 0.5),
          ),
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    activeColor.withValues(alpha: 0.92),
                    activeColor.withValues(alpha: 0.78),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.white.withValues(alpha: 0.62),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? activeColor.withValues(alpha: 0.24)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSelected ? 14 : 8,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : inactiveTextColor,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _OurGalleryGrid extends ConsumerWidget {
  const _OurGalleryGrid({required this.filtered, required this.viewedIds});

  final List<GalleryItem> filtered;
  final Set<String> viewedIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    );

    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: filtered.length,
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.68,
      ),
      itemBuilder: (context, index) {
        final item = filtered[index];
        final viewed = viewedIds.contains(item.id);
        return GestureDetector(
          onTap: () async {
            HapticFeedback.lightImpact();
            await ref
                .read(progressControllerProvider.notifier)
                .markGalleryViewed(item.id, filtered.length);
            if (!context.mounted) return;
            Navigator.of(context).push(
              _heroRoute(
                GalleryViewerScreen(oursItems: filtered, initialIndex: index),
              ),
            );
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Shadow Layer
              Positioned(
                top: 15,
                left: 10,
                right: 10,
                bottom: -5,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 25,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                ),
              ),
              // Main Card
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'gallery-${item.id}',
                        child: Image.asset(
                          item.imageAsset,
                          fit: BoxFit.cover,
                          cacheWidth: 480,
                        ),
                      ),
                      // Dramatic Gradient Overlay
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.1),
                                Colors.black.withValues(alpha: 0.75),
                              ],
                              stops: const [0.0, 0.6, 1.0],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.caption,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                height: 1.3,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Seychelles 2026',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Glass Badges
              Positioned(
                top: 14,
                right: 14,
                child: _OverlayBadge(
                  child: Icon(
                    viewed ? LucideIcons.eye : LucideIcons.eyeOff,
                    size: 13,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                top: 14,
                left: 14,
                child: Consumer(
                  builder: (context, ref, child) {
                    final progress =
                        ref.watch(progressControllerProvider).valueOrNull;
                    final isFav =
                        progress?.favoriteIds.contains(item.id) ?? false;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        ref
                            .read(progressControllerProvider.notifier)
                            .toggleFavorite(item.id);
                      },
                      child: _OverlayBadge(
                        active: isFav,
                        child: Icon(
                          isFav
                              ? Icons.favorite_rounded
                              : Icons.favorite_outline_rounded,
                          size: 13,
                          color: isFav ? Colors.white : Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms, delay: (index * 40).ms).scale(
                begin: const Offset(0.95, 0.95),
                curve: Curves.easeOutBack,
              ),
        );
      },
    );
  }
}

class _OverlayBadge extends StatelessWidget {
  const _OverlayBadge({required this.child, this.active = false});
  final Widget child;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: active
                ? AppColors.pastelPink.withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _UserCollectionsView extends ConsumerWidget {
  const _UserCollectionsView({required this.collections});
  final List<UserGalleryCollection> collections;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        PastelCard(
          child: ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.pastelPink.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.plusCircle,
                color: AppColors.pastelPink,
                size: 20,
              ),
            ),
            title: const Text('New Collection'),
            trailing: const Icon(
              LucideIcons.chevronRight,
              size: 18,
              color: AppColors.textMuted,
            ),
            onTap: () => _showAddCollectionDialog(context, ref),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: collections.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.heart,
                        size: 48,
                        color: AppColors.pastelPink.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Create your first collection, Baby ✨',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ).animate().fadeIn(duration: 500.ms),
                )
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: collections.length,
                  itemBuilder: (context, index) {
                    final col = collections[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child:
                          PastelCard(
                                child: ListTile(
                                  leading: col.images.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.file(
                                            File(col.images.first.filePath),
                                            width: 44,
                                            height: 44,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: AppColors.pastelLavender
                                                .withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Icon(
                                            LucideIcons.image,
                                            color: AppColors.pastelLavender,
                                            size: 20,
                                          ),
                                        ),
                                  title: Text(
                                    col.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${col.images.length} memories',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  trailing: const Icon(
                                    Icons.chevron_right,
                                    color: AppColors.textMuted,
                                    size: 20,
                                  ),
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          UserCollectionScreen(collection: col),
                                    ),
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: (index * 40).ms)
                              .slideX(begin: 0.04),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showAddCollectionDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('New Collection'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. Our Dates'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref
                    .read(userGalleryControllerProvider.notifier)
                    .addCollection(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class UserCollectionScreen extends ConsumerWidget {
  const UserCollectionScreen({super.key, required this.collection});
  final UserGalleryCollection collection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(userGalleryControllerProvider).value ?? [];
    final current = collections.firstWhere(
      (c) => c.id == collection.id,
      orElse: () => collection,
    );

    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(current.name),
          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            MediaQuery.of(context).padding.top + kToolbarHeight + 12,
            20,
            12,
          ),
          child: Column(
            children: [
              PastelCard(
                child: ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.pastelPink.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.imagePlus,
                      color: AppColors.pastelPink,
                      size: 18,
                    ),
                  ),
                  title: const Text('Add Memory'),
                  trailing: const Icon(
                    LucideIcons.chevronRight,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                  onTap: () => _addImage(context, ref, current.id),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: current.images.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.camera,
                              size: 48,
                              color: AppColors.pastelPink.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No memories yet',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ).animate().fadeIn(),
                      )
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1.0,
                            ),
                        itemCount: current.images.length,
                        itemBuilder: (context, index) {
                          final img = current.images[index];
                          return GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                  _heroRoute(
                                    GalleryViewerScreen(
                                      yoursItems: current.images,
                                      initialIndex: index,
                                    ),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    PastelCard(
                                      padding: const EdgeInsets.all(6),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: Hero(
                                          tag: 'user-${img.id}',
                                          child: Image.file(
                                            File(img.filePath),
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 10,
                                      left: 10,
                                      child: Consumer(
                                        builder: (context, ref, child) {
                                          final progress = ref
                                              .watch(progressControllerProvider)
                                              .valueOrNull;
                                          final isFav =
                                              progress?.favoriteIds.contains(
                                                img.id,
                                              ) ??
                                              false;
                                          return GestureDetector(
                                            onTap: () {
                                              HapticFeedback.lightImpact();
                                              ref
                                                  .read(
                                                    progressControllerProvider
                                                        .notifier,
                                                  )
                                                  .toggleFavorite(img.id);
                                            },
                                            child: _OverlayBadge(
                                              child: Icon(
                                                isFav
                                                    ? Icons.favorite_rounded
                                                    : Icons
                                                          .favorite_outline_rounded,
                                                size: 14,
                                                color: isFav
                                                    ? AppColors.pastelPink
                                                    : AppColors.textPrimary,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 350.ms, delay: (index * 30).ms)
                              .scale(begin: const Offset(0.95, 0.95));
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addImage(
    BuildContext context,
    WidgetRef ref,
    String colId,
  ) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (pickedFile == null) return;

    final controller = TextEditingController();
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Add Caption'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Describe this moment...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Skip'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref
                    .read(userGalleryControllerProvider.notifier)
                    .addImageToCollection(
                      colId,
                      pickedFile.path,
                      controller.text,
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

// ── Gallery Viewer with swipe ─────────────────────────────────────────────────

class GalleryViewerScreen extends ConsumerStatefulWidget {
  const GalleryViewerScreen({
    super.key,
    this.oursItems,
    this.yoursItems,
    this.sanityItems,
    this.collectionId,
    this.initialIndex = 0,
  }) : assert(oursItems != null || yoursItems != null || sanityItems != null);

  final List<GalleryItem>? oursItems;
  final List<UserGalleryImage>? yoursItems;
  final List<SharedGalleryImage>? sanityItems;
  final String? collectionId;
  final int initialIndex;

  @override
  ConsumerState<GalleryViewerScreen> createState() =>
      _GalleryViewerScreenState();
}

class _GalleryViewerScreenState extends ConsumerState<GalleryViewerScreen> {
  late PageController _pageCtrl;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageCtrl = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  int get _total =>
      widget.oursItems?.length ??
      widget.yoursItems?.length ??
      widget.sanityItems?.length ??
      0;

  String _captionAt(int index) {
    if (widget.oursItems != null) return widget.oursItems![index].caption;
    if (widget.sanityItems != null) return widget.sanityItems![index].caption;
    return widget.yoursItems![index].caption;
  }

  String _heroTagAt(int index) {
    if (widget.oursItems != null) {
      return 'gallery-${widget.oursItems![index].id}';
    }
    if (widget.sanityItems != null) {
      return 'sanity-${widget.sanityItems![index].id}';
    }
    return 'user-${widget.yoursItems![index].id}';
  }

  String _idAt(int index) {
    if (widget.oursItems != null) return widget.oursItems![index].id;
    if (widget.sanityItems != null) return widget.sanityItems![index].id;
    return widget.yoursItems![index].id;
  }

  Widget _imageAt(int index) {
    if (widget.oursItems != null) {
      return Image.asset(
        widget.oursItems![index].imageAsset,
        fit: BoxFit.contain,
      );
    }
    if (widget.sanityItems != null) {
      return CachedNetworkImage(
        imageUrl: widget.sanityItems![index].imageUrl,
        fit: BoxFit.contain,
      );
    }
    return Image.file(
      File(widget.yoursItems![index].filePath),
      fit: BoxFit.contain,
    );
  }

  Widget _blurredBgAt(int index) {
    if (widget.oursItems != null) {
      return Image.asset(
        widget.oursItems![index].imageAsset,
        fit: BoxFit.cover,
        color: Colors.black.withValues(alpha: 0.15),
        colorBlendMode: BlendMode.darken,
      );
    }
    if (widget.sanityItems != null) {
      return CachedNetworkImage(
        imageUrl: widget.sanityItems![index].imageUrl,
        fit: BoxFit.cover,
        color: Colors.black.withValues(alpha: 0.15),
        colorBlendMode: BlendMode.darken,
      );
    }
    return Image.file(
      File(widget.yoursItems![index].filePath),
      fit: BoxFit.cover,
      color: Colors.black.withValues(alpha: 0.15),
      colorBlendMode: BlendMode.darken,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (widget.sanityItems != null && widget.collectionId != null)
            IconButton(
              icon: const Icon(LucideIcons.trash2, color: Colors.white70),
              onPressed: () => _confirmDeleteShared(context, ref),
              tooltip: 'Remove from collection',
            ),
          if (_total > 1)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${_currentIndex + 1} / $_total',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Blurred background that crossfades with page
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: SizedBox.expand(
              key: ValueKey(_currentIndex),
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                child: _blurredBgAt(_currentIndex),
              ),
            ),
          ),
          // Dark scrim over blur
          Container(color: Colors.black.withValues(alpha: 0.35)),

          // Swipeable page view
          PageView.builder(
            controller: _pageCtrl,
            itemCount: _total,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) {
              final isFirst = index == widget.initialIndex;
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  12,
                  MediaQuery.of(context).padding.top + kToolbarHeight + 8,
                  12,
                  100,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: isFirst
                      ? Hero(tag: _heroTagAt(index), child: _imageAt(index))
                      : _imageAt(index),
                ),
              );
            },
          ),

          // Caption + favorite bar at bottom
          Positioned(
            left: 16,
            right: 16,
            bottom: 16 + MediaQuery.of(context).padding.bottom,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _BottomInfoBar(
                key: ValueKey(_currentIndex),
                caption: _captionAt(_currentIndex),
                itemId: _idAt(_currentIndex),
              ),
            ),
          ),

          // Swipe hint dots
          if (_total > 1)
            Positioned(
              bottom: 88 + MediaQuery.of(context).padding.bottom,
              left: 0,
              right: 0,
              child: _SwipeDots(total: _total, current: _currentIndex),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteShared(BuildContext context, WidgetRef ref) async {
    final img = widget.sanityItems![_currentIndex];
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Remove photo?'),
        content: Text(
          img.caption.isEmpty
              ? 'This memory will be removed from the collection.'
              : '"${img.caption}" will be removed from the collection.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await ref
          .read(sanityRepositoryProvider)
          .removeImageFromSharedCollection(
            collectionId: widget.collectionId!,
            imageKey: img.key,
          );
      if (context.mounted) {
        Navigator.pop(context); // Close viewer
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Memory removed')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(sanityErrorMessage(e))));
      }
    }
  }
}

class _BottomInfoBar extends ConsumerWidget {
  const _BottomInfoBar({
    super.key,
    required this.caption,
    required this.itemId,
  });

  final String caption;
  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressControllerProvider).valueOrNull;
    final isFav = progress?.favoriteIds.contains(itemId) ?? false;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  caption.isEmpty ? '✨' : caption,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref
                      .read(progressControllerProvider.notifier)
                      .toggleFavorite(itemId);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isFav
                        ? AppColors.pastelPink.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFav
                        ? Icons.favorite_rounded
                        : Icons.favorite_outline_rounded,
                    color: isFav ? AppColors.pastelPink : Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwipeDots extends StatelessWidget {
  const _SwipeDots({required this.total, required this.current});
  final int total;
  final int current;

  @override
  Widget build(BuildContext context) {
    final visible = total.clamp(0, 12);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(visible, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.white38,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

class _FolderSwitcher extends StatelessWidget {
  const _FolderSwitcher({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: AppConfig.galleryFolders.entries.map((entry) {
          final isSelected = selected == entry.key;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onChanged(entry.key);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.pastelPeach.withValues(alpha: 0.92)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  entry.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Shared Collections (Sanity) ───────────────────────────────────────────────

class _SharedCollectionsView extends ConsumerWidget {
  const _SharedCollectionsView({required this.collections});

  final List<SharedGalleryCollection> collections;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAuthorAsync = ref.watch(authorProvider);
    final currentAuthor = currentAuthorAsync.value ?? 'Mimi Boy';

    return Column(
      children: [
        // Author chip row + new-collection button
        Row(
          children: [
            for (final a in ['Mimi Boy', 'Mimi Girl'])
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => ref.read(authorProvider.notifier).setAuthor(a),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: currentAuthor == a
                          ? AppColors.pastelPink.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.42),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: currentAuthor == a
                            ? AppColors.pastelPink.withValues(alpha: 0.4)
                            : Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Text(
                      a,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: currentAuthor == a
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: currentAuthor == a
                            ? AppColors.pastelPink
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            const Spacer(),
            GestureDetector(
              onTap: () => _showCreateDialog(context, ref),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.62),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.plusCircle,
                      size: 14,
                      color: AppColors.textPrimary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'New',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // List
        Expanded(
          child: collections.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.imageOff,
                        size: 48,
                        color: AppColors.pastelPink.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No shared collections yet',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                  ).animate().fadeIn(duration: 500.ms),
                )
              : RefreshIndicator(
                  color: AppColors.pastelPink,
                  onRefresh: () async =>
                      ref.refresh(sharedCollectionsProvider.future),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: collections.length,
                    itemBuilder: (context, index) {
                      final col = collections[index];
                      final thumb = col.images.isNotEmpty
                          ? col.images.first.imageUrl
                          : null;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child:
                            PastelCard(
                                  child: ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: thumb != null && thumb.isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: thumb,
                                              width: 44,
                                              height: 44,
                                              fit: BoxFit.cover,
                                              placeholder: (_, __) => Container(
                                                width: 44,
                                                height: 44,
                                                color: AppColors.pastelLavender
                                                    .withValues(alpha: 0.15),
                                              ),
                                            )
                                          : Container(
                                              width: 44,
                                              height: 44,
                                              color: AppColors.pastelLavender
                                                  .withValues(alpha: 0.15),
                                              child: const Icon(
                                                LucideIcons.image,
                                                color: AppColors.pastelLavender,
                                                size: 20,
                                              ),
                                            ),
                                    ),
                                    title: Text(
                                      col.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${col.images.length} memories · by ${col.createdBy}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    trailing: const Icon(
                                      Icons.chevron_right,
                                      color: AppColors.textMuted,
                                      size: 20,
                                    ),
                                    onTap: () => Navigator.of(context)
                                        .push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                SharedCollectionScreen(
                                                  collection: col,
                                                ),
                                          ),
                                        )
                                        .then((_) {
                                          ref.invalidate(
                                            sharedCollectionsProvider,
                                          );
                                        }),
                                  ),
                                )
                                .animate()
                                .fadeIn(
                                  duration: 400.ms,
                                  delay: (index * 40).ms,
                                )
                                .slideX(begin: 0.04),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    final authorAsync = ref.read(authorProvider);
    final author = authorAsync.value ?? 'Mimi Boy';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('New Shared Collection'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. Our Dates'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              final repo = ref.read(sanityRepositoryProvider);
              await repo.createSharedCollection(
                name: ctrl.text.trim(),
                createdBy: author,
              );
              ref.invalidate(sharedCollectionsProvider);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

// ── Shared Collection detail screen ───────────────────────────────────────────

class SharedCollectionScreen extends ConsumerStatefulWidget {
  const SharedCollectionScreen({super.key, required this.collection});

  final SharedGalleryCollection collection;

  @override
  ConsumerState<SharedCollectionScreen> createState() =>
      _SharedCollectionScreenState();
}

class _SharedCollectionScreenState
    extends ConsumerState<SharedCollectionScreen> {
  bool _uploading = false;

  @override
  Widget build(BuildContext context) {
    final collsAsync = ref.watch(sharedCollectionsProvider);
    final col =
        collsAsync.valueOrNull?.firstWhere(
          (c) => c.id == widget.collection.id,
          orElse: () => widget.collection,
        ) ??
        widget.collection;

    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(col.name),
          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          actions: [
            if (_uploading)
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.pastelPink,
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            MediaQuery.of(context).padding.top + kToolbarHeight + 12,
            20,
            12,
          ),
          child: Column(
            children: [
              PastelCard(
                child: ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.pastelPink.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.imagePlus,
                      color: AppColors.pastelPink,
                      size: 18,
                    ),
                  ),
                  title: const Text('Add Memory'),
                  trailing: const Icon(
                    LucideIcons.chevronRight,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                  onTap: _uploading ? null : () => _addImage(col.id),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: col.images.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.camera,
                              size: 48,
                              color: AppColors.pastelPink.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No memories yet',
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                          ],
                        ).animate().fadeIn(),
                      )
                    : RefreshIndicator(
                        color: AppColors.pastelPink,
                        onRefresh: () async =>
                            ref.refresh(sharedCollectionsProvider.future),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 1.0,
                              ),
                          itemCount: col.images.length,
                          itemBuilder: (context, index) {
                            final img = col.images[index];
                            return GestureDetector(
                                  onTap: () => Navigator.of(context).push(
                                    _heroRoute(
                                      GalleryViewerScreen(
                                        sanityItems: col.images,
                                        collectionId: col.id,
                                        initialIndex: index,
                                      ),
                                    ),
                                  ),
                                  onLongPress: () => _confirmDelete(
                                    col.id,
                                    img.key,
                                    img.caption,
                                  ),
                                  child: Stack(
                                    children: [
                                      PastelCard(
                                        padding: const EdgeInsets.all(6),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: img.imageUrl,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                            placeholder: (_, __) => Container(
                                              color: AppColors.pastelLavender
                                                  .withValues(alpha: 0.15),
                                            ),
                                            errorWidget: (_, __, ___) =>
                                                const Icon(
                                                  LucideIcons.imageOff,
                                                ),
                                          ),
                                        ),
                                      ),
                                      // Upload-by badge
                                      if (img.uploadedBy.isNotEmpty)
                                        Positioned(
                                          bottom: 10,
                                          left: 10,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(
                                                alpha: 0.45,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              img.uploadedBy,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                )
                                .animate()
                                .fadeIn(
                                  duration: 350.ms,
                                  delay: (index * 30).ms,
                                )
                                .scale(begin: const Offset(0.95, 0.95));
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addImage(String collectionId) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    final captionCtrl = TextEditingController();
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Add Caption'),
        content: TextField(
          controller: captionCtrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Describe this moment…'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Upload'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    setState(() => _uploading = true);
    try {
      final repo = ref.read(sanityRepositoryProvider);
      final assetId = await repo.uploadImageAsset(File(picked.path));
      await repo.addImageToSharedCollection(
        collectionId: collectionId,
        assetId: assetId,
        caption: captionCtrl.text.trim(),
        uploadedBy: ref.read(authorProvider).value ?? 'Mimi Boy',
      );
      ref.invalidate(sharedCollectionsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(sanityErrorMessage(e))));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _confirmDelete(
    String collectionId,
    String imageKey,
    String caption,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Remove photo?'),
        content: Text(
          caption.isEmpty
              ? 'This memory will be removed from the collection.'
              : '"$caption" will be removed from the collection.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref
          .read(sanityRepositoryProvider)
          .removeImageFromSharedCollection(
            collectionId: collectionId,
            imageKey: imageKey,
          );
      ref.invalidate(sharedCollectionsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(sanityErrorMessage(e))));
      }
    }
  }
}

// ── Route helper ──────────────────────────────────────────────────────────────

PageRouteBuilder<void> _heroRoute(Widget page) {
  return PageRouteBuilder<void>(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}
