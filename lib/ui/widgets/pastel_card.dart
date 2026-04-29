import 'package:flutter/material.dart';

class PastelCard extends StatelessWidget {
  const PastelCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.gradient,
    this.enableReveal = true,
    this.enablePressFeedback = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Gradient? gradient;
  final bool enableReveal;
  final bool enablePressFeedback;

  @override
  Widget build(BuildContext context) {
    final dynamicContrastColor = Theme.of(context).primaryColor;

    final baseCard = Container(
      margin: margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: gradient,
        color: gradient == null
            ? const Color(0xFFFFF1F6).withValues(alpha: 0.95)
            : null,
        border: Border.all(
          color: dynamicContrastColor.withValues(alpha: 0.08),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Theme(
          data: Theme.of(context).copyWith(
            textTheme: Theme.of(context).textTheme.apply(
              bodyColor: const Color(0xFF1E1E1E),
              displayColor: const Color(0xFF1E1E1E),
            ),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );

    final interactiveCard = enablePressFeedback
        ? _CardPressFeedback(child: baseCard)
        : baseCard;

    return interactiveCard;
  }
}

class _CardPressFeedback extends StatefulWidget {
  const _CardPressFeedback({required this.child});

  final Widget child;

  @override
  State<_CardPressFeedback> createState() => _CardPressFeedbackState();
}

class _CardPressFeedbackState extends State<_CardPressFeedback> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 1.018 : 1,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: Stack(
          children: [
            widget.child,
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _pressed ? 1 : 0,
                  duration: const Duration(milliseconds: 130),
                  curve: Curves.easeOut,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
