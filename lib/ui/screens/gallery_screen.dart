import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/constants/app_config.dart';
import '../../domain/entities.dart';
import '../theme.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/pastel_card.dart';
import '../widgets/skeleton_loader.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key});

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

enum GalleryTab { ours, yours }

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  String _selectedFolder = 'seychelles';
  GalleryTab _currentTab = GalleryTab.ours;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      ref.read(progressControllerProvider.notifier).updateLastGalleryFolder(AppConfig.galleryFolders[_selectedFolder] ?? _selectedFolder);

      final shouldShow = await ref
          .read(progressControllerProvider.notifier)
          .showGalleryIntroIfNeeded();
      if (!mounted || !shouldShow) return;
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('For you, Mimi'),
            content: const Text(
              'I know you dont like all of these pics but they make up our essence, '
              'and have a lot of meaning to me... some are just what i could find of us together alone. '
              'Anyways i hope you enjoy mimi!',
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Memories'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _TabButton(
                  label: 'Ours',
                  isSelected: _currentTab == GalleryTab.ours,
                  onTap: () => setState(() => _currentTab = GalleryTab.ours),
                ),
                const SizedBox(width: 12),
                _TabButton(
                  label: 'Yours',
                  isSelected: _currentTab == GalleryTab.yours,
                  onTap: () => setState(() => _currentTab = GalleryTab.yours),
                ),
              ],
            ),
          ),
        ),
      ),
      body: AnimatedGradientBackground(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            MediaQuery.of(context).padding.top + kToolbarHeight + 70,
            20,
            12,
          ),
          child: _currentTab == GalleryTab.ours
              ? contentAsync.when(
                  data: (content) {
                    final filtered = content.gallery
                        .where((item) => item.imageAsset.contains('/$_selectedFolder/'))
                        .toList();
                    final viewedIds = ref.watch(progressControllerProvider).value?.galleryViewedIds ?? <String>{};
                    return Column(
                      children: [
                        _FolderSwitcher(
                          selected: _selectedFolder,
                          onChanged: (value) {
                            setState(() => _selectedFolder = value);
                            ref.read(progressControllerProvider.notifier).updateLastGalleryFolder(AppConfig.galleryFolders[value] ?? value);
                          },
                        ),
                        const SizedBox(height: 14),
                        Expanded(child: _OurGalleryGrid(filtered: filtered, viewedIds: viewedIds)),
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
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 0.9,
                          ),
                          itemBuilder: (context, index) => const SkeletonLoader(),
                        ),
                      ),
                    ],
                  ),
                  error: (error, _) => Text('Error: $error'),
                )
              : userCollectionsAsync.when(
                  data: (collections) => _UserCollectionsView(collections: collections),
                  loading: () => Column(
                    children: [
                      const SkeletonLoader(height: 70),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: 4,
                          itemBuilder: (context, index) => const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: SkeletonLoader(height: 80),
                          ),
                        ),
                      ),
                    ],
                  ),
                  error: (error, _) => Text('Error: $error'),
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
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.pastelPink : Colors.white.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.pastelPink.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
    return GridView.builder(
      padding: EdgeInsets.zero,
      itemCount: filtered.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        final item = filtered[index];
        final viewed = viewedIds.contains(item.id);
        return GestureDetector(
          onTap: () async {
            HapticFeedback.lightImpact();
            // In a real app we'd use the actual count, but for here 100 is fine
            await ref.read(progressControllerProvider.notifier).markGalleryViewed(item.id, 100); 
            if (!context.mounted) return;
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => GalleryViewerScreen(ours: item)));
          },
          child: Stack(
            children: [
              PastelCard(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Hero(
                          tag: item.id,
                          child: ColorFiltered(
                            colorFilter: viewed
                                ? const ColorFilter.mode(Colors.transparent, BlendMode.srcOver)
                                : ColorFilter.mode(Colors.white.withValues(alpha: 0.3), BlendMode.modulate),
                            child: Image.asset(item.imageAsset, fit: BoxFit.cover, cacheWidth: 400),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(item.caption, style: Theme.of(context).textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Positioned(
                top: 10, right: 10,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(999)),
                  child: Icon(viewed ? LucideIcons.eye : LucideIcons.eyeOff, size: 16, color: AppColors.textPrimary),
                ),
              ),
              Positioned(
                top: 10, left: 10,
                child: Consumer(
                  builder: (context, ref, child) {
                    final progress = ref.watch(progressControllerProvider).valueOrNull;
                    final isFav = progress?.favoriteIds.contains(item.id) ?? false;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(progressControllerProvider.notifier).toggleFavorite(item.id);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(999)),
                        child: Icon(
                          isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded, 
                          size: 16, 
                          color: isFav ? AppColors.pastelPink : AppColors.textPrimary,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms, delay: (index * 30).ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOut),
        );
      },
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
            leading: const Icon(LucideIcons.plusCircle, color: AppColors.pastelPink),
            title: const Text('Add New Collection'),
            onTap: () => _showAddCollectionDialog(context, ref),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: collections.isEmpty
              ? const Center(child: Text('Create your first collection, Baby! ✨'))
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: collections.length,
                  itemBuilder: (context, index) {
                    final col = collections[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PastelCard(
                        child: ListTile(
                          title: Text(col.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${col.images.length} personal memories'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => UserCollectionScreen(collection: col))),
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: (index * 40).ms).slideX(begin: 0.05, end: 0, curve: Curves.easeOut);
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
        title: const Text('New Collection'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'e.g. Our Dates')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(userGalleryControllerProvider.notifier).addCollection(controller.text);
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
    final current = collections.firstWhere((c) => c.id == collection.id, orElse: () => collection);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(current.name),
        backgroundColor: Colors.transparent,
      ),
      body: AnimatedGradientBackground(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + kToolbarHeight + 12, 20, 12),
          child: Column(
            children: [
              PastelCard(
                child: ListTile(
                  leading: const Icon(LucideIcons.imagePlus, color: AppColors.pastelPink),
                  title: const Text('Add Memory'),
                  onTap: () => _addImage(context, ref, current.id),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: current.images.isEmpty
                    ? const Center(child: Text('No images yet'))
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, 
                          mainAxisSpacing: 14, 
                          crossAxisSpacing: 14,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: current.images.length,
                        itemBuilder: (context, index) {
                          final img = current.images[index];
                          return GestureDetector(
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GalleryViewerScreen(yours: img))),
                            child: Stack(
                              children: [
                                PastelCard(
                                  padding: const EdgeInsets.all(8),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(File(img.filePath), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                                  ),
                                ),
                                Positioned(
                                  top: 10, left: 10,
                                  child: Consumer(
                                    builder: (context, ref, child) {
                                      final progress = ref.watch(progressControllerProvider).valueOrNull;
                                      final isFav = progress?.favoriteIds.contains(img.id) ?? false;
                                      return GestureDetector(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          ref.read(progressControllerProvider.notifier).toggleFavorite(img.id);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(999)),
                                          child: Icon(
                                            isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded, 
                                            size: 16, 
                                            color: isFav ? AppColors.pastelPink : AppColors.textPrimary,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addImage(BuildContext context, WidgetRef ref, String colId) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final controller = TextEditingController();
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Caption'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Describe this moment...')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(userGalleryControllerProvider.notifier).addImageToCollection(colId, pickedFile.path, controller.text);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class GalleryViewerScreen extends ConsumerWidget {
  const GalleryViewerScreen({super.key, this.ours, this.yours});

  final GalleryItem? ours;
  final UserGalleryImage? yours;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caption = ours?.caption ?? yours?.caption ?? '';
    final tag = ours?.id ?? yours?.id ?? '';

    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: AnimatedGradientBackground(
        child: Stack(
          children: [
            Positioned.fill(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: ours != null 
                    ? Image.asset(ours!.imageAsset, fit: BoxFit.cover, color: Colors.black.withValues(alpha: 0.1), colorBlendMode: BlendMode.darken)
                    : Image.file(File(yours!.filePath), fit: BoxFit.cover, color: Colors.black.withValues(alpha: 0.1), colorBlendMode: BlendMode.darken),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Hero(
                        tag: tag,
                        child: ours != null 
                            ? Image.asset(ours!.imageAsset, fit: BoxFit.cover)
                            : Image.file(File(yours!.filePath), fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  PastelCard(
                    child: Row(
                      children: [
                        Expanded(child: Text(caption, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center)),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref.read(progressControllerProvider.notifier).toggleFavorite(tag);
                          },
                          child: Consumer(
                            builder: (context, ref, _) {
                              final progress = ref.watch(progressControllerProvider).valueOrNull;
                              final isFav = progress?.favoriteIds.contains(tag) ?? false;
                              return Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isFav ? AppColors.pastelPink.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                                  color: isFav ? AppColors.pastelPink : AppColors.textPrimary,
                                  size: 24,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FolderSwitcher extends StatelessWidget {
  const _FolderSwitcher({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return PastelCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: AppConfig.galleryFolders.entries.map((entry) {
          final isSelected = selected == entry.key;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(entry.value),
                selected: isSelected,
                onSelected: (_) {
                  HapticFeedback.lightImpact();
                  onChanged(entry.key);
                },
                selectedColor: AppColors.pastelPeach,
                backgroundColor: Colors.white.withValues(alpha: 0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
