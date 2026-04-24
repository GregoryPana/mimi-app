import 'package:flutter/material.dart';

class PastelCard extends StatelessWidget {
  const PastelCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.gradient,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      margin: margin ?? EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: gradient,
          color: gradient == null
              ? const Color(0xFFFFF1F6).withValues(alpha: 0.92)
              : null,
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}
