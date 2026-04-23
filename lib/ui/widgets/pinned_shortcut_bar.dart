import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme.dart';

class PinnedShortcutBar extends StatelessWidget {
  const PinnedShortcutBar({
    super.key,
    required this.pinnedItems,
    required this.onTap,
  });

  final List<PinnedFeature> pinnedItems;
  final Function(PinnedFeature) onTap;

  @override
  Widget build(BuildContext context) {
    if (pinnedItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              const Icon(LucideIcons.pin, size: 14, color: AppColors.pastelPink),
              const SizedBox(width: 6),
              Text(
                'Pinned for quick access',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: pinnedItems.length,
            itemBuilder: (context, index) {
              final item = pinnedItems[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => onTap(item),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              item.color.withValues(alpha: 0.8),
                              item.color,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: item.color.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(item.icon, color: Colors.white, size: 24),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.label,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.2, end: 0);
            },
          ),
        ),
      ],
    );
  }
}

class PinnedFeature {
  final String id;
  final String label;
  final IconData icon;
  final Color color;

  PinnedFeature({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });
}
