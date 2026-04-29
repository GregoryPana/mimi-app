import 'dart:math';

import 'package:flutter/material.dart';

import 'floating_hearts_background.dart';

class AnimatedGradientBackground extends StatefulWidget {
  const AnimatedGradientBackground({super.key, required this.child});

  final Widget child;

  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const List<List<Color>> _palettes = [
    [Color(0xFFFF8A80), Color(0xFFF8BBD0), Color(0xFFD1C4E9)],
    [Color(0xFFFF5252), Color(0xFFF48FB1), Color(0xFFB39DDB)],
    [Color(0xFFFFCDD2), Color(0xFFF06292), Color(0xFFC5B3FF)],
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Color> _currentPalette(double t) {
    final scaled = t * _palettes.length;
    final index = scaled.floor() % _palettes.length;
    final nextIndex = (index + 1) % _palettes.length;
    final localT = scaled - scaled.floor();

    final current = _palettes[index];
    final next = _palettes[nextIndex];
    return List<Color>.generate(current.length, (i) {
      return Color.lerp(current[i], next[i], localT) ?? current[i];
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final colors = _currentPalette(t);
        final drift = sin(t * 2 * pi) * 0.6;
        final begin = Alignment(-1 + drift, -1);
        final end = Alignment(1 - drift, 1);

        // Calculate dynamic contrast color
        final avgLuminance = colors.map((c) => c.computeLuminance()).reduce((a, b) => a + b) / colors.length;
        final bool isLightBackground = avgLuminance > 0.6;
        
        // Use a very dark pink for light backgrounds, and white for darker/saturated backgrounds
        final contrastColor = isLightBackground ? const Color(0xFF880E4F) : Colors.white;
        final secondaryColor = isLightBackground ? const Color(0xFF4A148C).withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.85);

        return GradientContrast(
          color: contrastColor,
          secondaryColor: secondaryColor,
          isLightBackground: isLightBackground,
          child: Theme(
            data: Theme.of(context).copyWith(
              primaryColor: contrastColor,
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: contrastColor,
                secondary: secondaryColor,
              ),
              // Update default text theme for this subtree
              textTheme: Theme.of(context).textTheme.copyWith(
                headlineSmall: Theme.of(context).textTheme.headlineSmall?.copyWith(color: contrastColor),
                titleLarge: Theme.of(context).textTheme.titleLarge?.copyWith(color: contrastColor),
                titleMedium: Theme.of(context).textTheme.titleMedium?.copyWith(color: contrastColor),
                titleSmall: Theme.of(context).textTheme.titleSmall?.copyWith(color: contrastColor),
                bodyLarge: Theme.of(context).textTheme.bodyLarge?.copyWith(color: contrastColor),
                bodyMedium: Theme.of(context).textTheme.bodyMedium?.copyWith(color: secondaryColor),
                bodySmall: Theme.of(context).textTheme.bodySmall?.copyWith(color: secondaryColor),
              ),
              iconTheme: IconThemeData(color: contrastColor),
            ),
            child: SizedBox.expand(
              child: Stack(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: colors,
                        begin: begin,
                        end: end,
                      ),
                    ),
                    child: const SizedBox.expand(),
                  ),
                  const Positioned.fill(
                    child: FloatingHeartsBackground(),
                  ),
                  child ?? const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

class GradientContrast extends InheritedWidget {
  const GradientContrast({
    super.key,
    required this.color,
    required this.secondaryColor,
    required this.isLightBackground,
    required super.child,
  });

  final Color color;
  final Color secondaryColor;
  final bool isLightBackground;

  static GradientContrast? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<GradientContrast>();
  }

  static Color colorOf(BuildContext context) {
    return maybeOf(context)?.color ?? const Color(0xFFE56B98); // Fallback to pastelPink
  }

  @override
  bool updateShouldNotify(GradientContrast oldWidget) =>
      color != oldWidget.color || secondaryColor != oldWidget.secondaryColor;
}
