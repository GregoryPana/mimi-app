import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                bg.withValues(alpha: 0.8),
                bg.withValues(alpha: 0.4),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: bg.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Thumbnail / icon
              Container(
                width: 60,
                height: 60,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: widget.imageAsset != null
                    ? Image.asset(widget.imageAsset!, fit: BoxFit.cover, cacheWidth: 200)
                    : Icon(
                        widget.icon ?? Icons.play_arrow_rounded,
                        color: AppColors.textPrimary,
                        size: 28,
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(height: 2),
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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.pastelPink.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_forward_rounded, size: 20, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    ).animate().scale(delay: 100.ms, begin: const Offset(0.95, 0.95), end: const Offset(1, 1), curve: Curves.easeOutBack);
  }
}
