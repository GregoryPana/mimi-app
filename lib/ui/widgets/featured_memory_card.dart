import 'package:flutter/material.dart';

import '../theme.dart';

/// Large hero card showing a featured gallery image with gradient overlay
/// and a label at the bottom. Matches the "FEATURED MEMORY" section
/// in the reference design.
class FeaturedMemoryCard extends StatelessWidget {
  const FeaturedMemoryCard({
    super.key,
    required this.imageAsset,
    required this.caption,
    this.isFavorited = false,
    this.onTap,
    this.onFavoriteTap,
  });

  final String imageAsset;
  final String caption;
  final bool isFavorited;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 220,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.pastelPink.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                cacheWidth: 800,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.pastelPeach.withValues(alpha: 0.3),
                  child: const Center(
                    child: Icon(Icons.photo, size: 48, color: Colors.white54),
                  ),
                ),
              ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.55),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
            // Favorite button (top right)
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: onFavoriteTap,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFavorited ? Icons.favorite : Icons.favorite_border,
                    size: 18,
                    color: isFavorited ? AppColors.pastelPink : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            // Caption and CTA at bottom
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$caption 📸',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'Tap to relive this moment',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, size: 16, color: Colors.white70),
                    ],
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
