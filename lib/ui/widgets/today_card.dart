import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme.dart';

/// "TODAY IN OUR STORY" card showing a timeline event that matches
/// today's date. Horizontal layout with optional thumbnail.
class TodayCard extends StatelessWidget {
  const TodayCard({
    super.key,
    required this.title,
    required this.relativeText,
    this.imageAsset,
    this.onTap,
  });

  final String title;
  final String relativeText;
  final String? imageAsset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (onTap != null) onTap!();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.pastelPink.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail or placeholder
            Container(
              width: 60,
              height: 60,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.pastelPeach.withValues(alpha: 0.3),
              ),
              child: imageAsset != null
                  ? Image.asset(imageAsset!, fit: BoxFit.cover, cacheWidth: 200)
                  : const Center(
                      child: Icon(Icons.auto_stories, color: AppColors.pastelPink, size: 28),
                    ),
            ),
            const SizedBox(width: 12),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: AppColors.pastelPink),
                      const SizedBox(width: 4),
                      Text(
                        'TODAY IN OUR STORY',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.pastelPink,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$title 💖',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    relativeText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            // Chevron
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.pastelPink.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chevron_right, color: AppColors.pastelPink, size: 18),
            ),
          ],
        ),
      ),
    ).animate().scale(delay: 100.ms, begin: const Offset(0.95, 0.95), end: const Offset(1, 1), curve: Curves.easeOutBack);
  }
}
