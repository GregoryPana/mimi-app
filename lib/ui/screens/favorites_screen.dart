import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/entities.dart';
import '../theme.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/pastel_card.dart';
import 'gallery_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentAsync = ref.watch(contentProvider);
    final progressAsync = ref.watch(progressControllerProvider);
    final userCollectionsAsync = ref.watch(userGalleryControllerProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: AnimatedGradientBackground(
        child: contentAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.pastelPink)),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (content) {
            final progress = progressAsync.valueOrNull;
            if (progress == null) return const SizedBox.shrink();

            final favIds = progress.favoriteIds;

            // Gather favored curated gallery items
            final favOurs = content.gallery.where((item) => favIds.contains(item.id)).toList();

            // Gather favored user gallery items
            final favYours = <UserGalleryImage>[];
            final userCollections = userCollectionsAsync.valueOrNull ?? [];
            for (final col in userCollections) {
              for (final img in col.images) {
                if (favIds.contains(img.id)) {
                  favYours.add(img);
                }
              }
            }

            if (favOurs.isEmpty && favYours.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.favorite_outline, size: 64, color: AppColors.pastelPink),
                    const SizedBox(height: 16),
                    Text(
                      'No favorites yet',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Heart your favorite memories\nand they will appear here.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ).animate().fadeIn().slideY(begin: 0.1),
              );
            }

            return GridView.builder(
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).padding.top + kToolbarHeight + 20,
                20,
                40,
              ),
              itemCount: favOurs.length + favYours.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (context, index) {
                if (index < favOurs.length) {
                  final item = favOurs[index];
                  return _buildFavOur(context, ref, item, index);
                } else {
                  final img = favYours[index - favOurs.length];
                  return _buildFavYours(context, ref, img, index);
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildFavOur(BuildContext context, WidgetRef ref, GalleryItem item, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => GalleryViewerScreen(oursItems: [item], initialIndex: 0)));
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
                      tag: 'fav_\${item.id}',
                      child: Image.asset(item.imageAsset, fit: BoxFit.cover, cacheWidth: 400),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(item.caption, style: Theme.of(context).textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Positioned(
            top: 10, left: 10,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(progressControllerProvider.notifier).toggleFavorite(item.id);
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(999)),
                child: const Icon(Icons.favorite_rounded, size: 16, color: AppColors.pastelPink),
              ),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms, delay: (index * 30).ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOut),
    );
  }

  Widget _buildFavYours(BuildContext context, WidgetRef ref, UserGalleryImage img, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => GalleryViewerScreen(yoursItems: [img], initialIndex: 0)));
      },
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
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(progressControllerProvider.notifier).toggleFavorite(img.id);
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(999)),
                child: const Icon(Icons.favorite_rounded, size: 16, color: AppColors.pastelPink),
              ),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms, delay: (index * 30).ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOut),
    );
  }
}
