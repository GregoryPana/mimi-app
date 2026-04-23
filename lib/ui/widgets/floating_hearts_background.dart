import 'dart:math';

import 'package:flutter/material.dart';


class FloatingHeartsBackground extends StatefulWidget {
  const FloatingHeartsBackground({
    super.key,
    this.count = 16,
    this.opacity = 0.18,
  });

  final int count;
  final double opacity;

  @override
  State<FloatingHeartsBackground> createState() => _FloatingHeartsBackgroundState();
}

class _FloatingHeartsBackgroundState extends State<FloatingHeartsBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_HeartParticle> _particles;

  @override
  void initState() {
    super.initState();
    final random = Random(42);
    _particles = List.generate(widget.count, (_) => _HeartParticle.random(random));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _HeartsPainter(
              progress: _controller.value,
              particles: _particles,
              opacity: widget.opacity,
            ),
          );
        },
      ),
    );
  }
}

class _HeartParticle {
  _HeartParticle({
    required this.xFactor,
    required this.yFactor,
    required this.speed,
    required this.size,
    required this.phase,
    required this.colorIndex,
  });

  final double xFactor;
  final double yFactor;
  final double speed;
  final double size;
  final double phase;
  final int colorIndex;

  factory _HeartParticle.random(Random random) {
    return _HeartParticle(
      xFactor: random.nextDouble(),
      yFactor: random.nextDouble(),
      speed: 0.15 + random.nextDouble() * 0.35,
      size: 10 + random.nextDouble() * 14,
      phase: random.nextDouble() * pi * 2,
      colorIndex: random.nextInt(5),
    );
  }
}

class _HeartsPainter extends CustomPainter {
  _HeartsPainter({
    required this.progress,
    required this.particles,
    required this.opacity,
  });

  final double progress;
  final List<_HeartParticle> particles;
  final double opacity;

  static const List<Color> _colors = [
    Color(0xFFE57373),
    Color(0xFFEF5350),
    Color(0xFFF06292),
    Color(0xFFD32F2F),
    Color(0xFFFF8A80),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    for (final particle in particles) {
      final baseX = particle.xFactor * size.width;
      final baseY = particle.yFactor * size.height;
      final drift = sin(progress * 2 * pi + particle.phase) * 8;
      final travel = progress * particle.speed * size.height * 1.6;
      double y = baseY - travel;
      y = (y % size.height + size.height) % size.height;

      final paint = Paint()
        ..color = _colors[particle.colorIndex].withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      final path = _heartPath(Offset(baseX + drift, y), particle.size);
      canvas.drawPath(path, paint);
    }
  }

  Path _heartPath(Offset center, double size) {
    final double width = size;
    final double height = size * 0.95;
    final double x = center.dx;
    final double y = center.dy;

    final path = Path();
    path.moveTo(x, y + height * 0.35);
    path.cubicTo(
      x + width * 0.55,
      y - height * 0.1,
      x + width * 0.95,
      y + height * 0.25,
      x,
      y + height * 0.9,
    );
    path.cubicTo(
      x - width * 0.95,
      y + height * 0.25,
      x - width * 0.55,
      y - height * 0.1,
      x,
      y + height * 0.35,
    );
    return path;
  }

  @override
  bool shouldRepaint(covariant _HeartsPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.opacity != opacity;
  }
}
