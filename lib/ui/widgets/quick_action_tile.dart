import 'package:flutter/material.dart';

import '../theme.dart';

/// Quick Action tile used in the 2×2 grid on the home screen.
/// Each tile has an icon, title, subtitle and navigates to a feature.
class QuickActionTile extends StatefulWidget {
  const QuickActionTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  State<QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<QuickActionTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: widget.backgroundColor.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon circle
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.backgroundColor.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: widget.iconColor, size: 22),
              ),
              const SizedBox(height: 10),
              // Title
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 16, color: AppColors.textSecondary),
                ],
              ),
              const SizedBox(height: 2),
              // Subtitle
              Text(
                widget.subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
