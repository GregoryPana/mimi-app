import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    this.isPinned = false,
    this.onPinToggle,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isPinned;
  final VoidCallback? onPinToggle;

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
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: widget.backgroundColor.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon circle & Favorite heart
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: widget.backgroundColor.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.icon, color: widget.iconColor, size: 20),
                  ),
                  if (widget.onPinToggle != null)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        widget.onPinToggle!();
                      },
                      icon: Icon(
                        widget.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                        color: widget.isPinned ? AppColors.pastelPink : AppColors.textSecondary.withValues(alpha: 0.5),
                        size: 18,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Title
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 14, color: AppColors.textSecondary),
                ],
              ),
              const SizedBox(height: 1),
              // Subtitle
              Text(
                widget.subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
