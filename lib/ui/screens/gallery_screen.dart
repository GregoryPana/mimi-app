import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/entities.dart';
import '../theme.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/pastel_card.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key});

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  String _selectedFolder = 'seychelles';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Memory Gallery'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: AnimatedGradientBackground(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            MediaQuery.of(context).padding.top + kToolbarHeight + 12,
            20,
            12,
          ),
          child: contentAsync.when(
            data: (content) {
              final filtered = content.gallery
                  .where((item) => item.imageAsset.contains('/$_selectedFolder/'))
                  .toList();
              final viewedIds = ref.watch(progressControllerProvider).value?.galleryViewedIds ?? <String>{};
              return Column(
                children: [
                  _FolderSwitcher(
                    selected: _selectedFolder,
                    onChanged: (value) => setState(() => _selectedFolder = value),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: GridView.builder(
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
                            await ref
                                .read(progressControllerProvider.notifier)
                                .markGalleryViewed(item.id, content.gallery.length);
                            if (!context.mounted) return;
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => GalleryViewerScreen(item: item),
                              ),
                            );
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
                                                ? const ColorFilter.mode(
                                                    Colors.transparent,
                                                    BlendMode.srcOver,
                                                  )
                                                : ColorFilter.mode(
                                                    Colors.white.withValues(alpha: 0.3),
                                                    BlendMode.modulate,
                                                  ),
                                            child: Image.asset(
                                              item.imageAsset,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      item.caption,
                                      style: Theme.of(context).textTheme.bodySmall,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(999),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.08),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    viewed ? LucideIcons.eye : LucideIcons.eyeOff,
                                    size: 16,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('Error: $error'),
          ),
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
        children: [
          Expanded(
            child: ChoiceChip(
              label: const Text('Seychelles'),
              selected: selected == 'seychelles',
              onSelected: (_) => onChanged('seychelles'),
              selectedColor: AppColors.pastelPeach,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ChoiceChip(
              label: const Text('Malaysia'),
              selected: selected == 'malaysia',
              onSelected: (_) => onChanged('malaysia'),
              selectedColor: AppColors.pastelPeach,
            ),
          ),
        ],
      ),
    );
  }
}

class GalleryViewerScreen extends StatelessWidget {
  const GalleryViewerScreen({super.key, required this.item});

  final GalleryItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: AnimatedGradientBackground(
        child: Stack(
          children: [
            Positioned.fill(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Image.asset(
                  item.imageAsset,
                  fit: BoxFit.cover,
                  color: Colors.black.withValues(alpha: 0.1),
                  colorBlendMode: BlendMode.darken,
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.2),
                      Colors.white.withValues(alpha: 0.35),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Hero(
                        tag: item.id,
                        child: Image.asset(item.imageAsset, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  PastelCard(
                    child: Text(
                      item.caption,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
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
