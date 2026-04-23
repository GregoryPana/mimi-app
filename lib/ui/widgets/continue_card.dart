import 'package:flutter/material.dart';

import '../theme.dart';

/// Small card showing last interaction with a feature (Comics or Gallery).
/// Used in the "Continue Where You Left Off" section.
class ContinueCard extends StatefulWidget {
  const ContinueCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.detail,
    this.imageAsset,
    this.icon,
    this.backgroundColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String detail;
  final String? imageAsset;
  final IconData? icon;
  final Color? backgroundColor;
  final VoidCallback onTap;

  @override
  State<ContinueCard> createState() => _ContinueCardState();
}

class _ContinueCardState extends State<ContinueCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.backgroundColor ?? AppColors.pastelPeach;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Thumbnail / icon
              Container(
                width: 46,
                height: 46,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: bg.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: widget.imageAsset != null
                    ? Image.asset(widget.imageAsset!, fit: BoxFit.cover, cacheWidth: 150)
                    : Icon(
                        widget.icon ?? Icons.play_arrow_rounded,
                        color: AppColors.textPrimary,
                        size: 24,
                      ),
              ),
              const SizedBox(width: 10),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      widget.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    Text(
                      widget.detail,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.pastelPink,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              // Chevron
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chevron_right, size: 16, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
