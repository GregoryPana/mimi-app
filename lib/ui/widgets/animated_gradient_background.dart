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

        return SizedBox.expand(
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
        );
      },
      child: widget.child,
    );
  }
}
