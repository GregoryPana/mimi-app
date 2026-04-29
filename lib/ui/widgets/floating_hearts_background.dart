import 'dart:math' as math;

import 'package:flutter/material.dart';

class FloatingHeartsBackground extends StatefulWidget {
  const FloatingHeartsBackground({
    super.key,
    this.count = 14,
    this.opacity = 0.16,
  });

  final int count;
  final double opacity;

  @override
  State<FloatingHeartsBackground> createState() =>
      _FloatingHeartsBackgroundState();
}

class _FloatingHeartsBackgroundState extends State<FloatingHeartsBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _intro;
  late final List<_HeartSpec> _hearts;

  @override
  void initState() {
    super.initState();
    final random = math.Random(1997);
    _hearts = List.generate(widget.count, (_) => _HeartSpec.random(random));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    _intro = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.25, curve: Curves.easeOutCubic),
    );
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
            painter: _CleanHeartsPainter(
              t: _controller.value,
              intro: _intro.value,
              hearts: _hearts,
              opacity: widget.opacity,
            ),
          );
        },
      ),
    );
  }
}

class _HeartSpec {
  const _HeartSpec({
    required this.lane,
    required this.offset,
    required this.speed,
    required this.size,
    required this.swing,
    required this.phase,
    required this.tintIndex,
  });

  final double lane;
  final double offset;
  final double speed;
  final double size;
  final double swing;
  final double phase;
  final int tintIndex;

  factory _HeartSpec.random(math.Random random) {
    return _HeartSpec(
      lane: 0.08 + random.nextDouble() * 0.84,
      offset: random.nextDouble(),
      speed: 0.42 + random.nextDouble() * 0.46,
      size: 8 + random.nextDouble() * 12,
      swing: 0.008 + random.nextDouble() * 0.022,
      phase: random.nextDouble() * math.pi * 2,
      tintIndex: random.nextInt(_CleanHeartsPainter.tints.length),
    );
  }
}

class _CleanHeartsPainter extends CustomPainter {
  const _CleanHeartsPainter({
    required this.t,
    required this.intro,
    required this.hearts,
    required this.opacity,
  });

  final double t;
  final double intro;
  final List<_HeartSpec> hearts;
  final double opacity;

  static const List<Color> tints = [
    Color(0xFFF5A3BC),
    Color(0xFFF28AAE),
    Color(0xFFEC7FA7),
    Color(0xFFF6B7CB),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final heartbeat = 0.97 + (math.sin(t * math.pi * 4) * 0.03);
    for (final heart in hearts) {
      final cycle = (t * heart.speed + heart.offset) % 1.0;
      final y = size.height * (1.08 - cycle * 1.16);
      final sway =
          math.sin((cycle * math.pi * 2) + heart.phase) *
          size.width *
          heart.swing;
      final x = size.width * heart.lane + sway;

      final fade = _softFade(cycle) * intro;
      if (fade <= 0.01) continue;

      final c = tints[heart.tintIndex].withValues(alpha: fade * opacity);
      final path = _heartPath(Offset(x, y), heart.size * heartbeat);

      canvas.drawPath(path, Paint()..color = c);
    }
  }

  double _softFade(double cycle) {
    if (cycle < 0.12) {
      return cycle / 0.12;
    }
    if (cycle > 0.84) {
      return (1.0 - cycle) / 0.16;
    }
    return 1.0;
  }

  Path _heartPath(Offset center, double size) {
    final w = size;
    final h = size * 0.96;
    final x = center.dx;
    final y = center.dy;

    return Path()
      ..moveTo(x, y + h * 0.34)
      ..cubicTo(
        x + w * 0.54,
        y - h * 0.14,
        x + w * 0.95,
        y + h * 0.21,
        x,
        y + h * 0.92,
      )
      ..cubicTo(
        x - w * 0.95,
        y + h * 0.21,
        x - w * 0.54,
        y - h * 0.14,
        x,
        y + h * 0.34,
      );
  }

  @override
  bool shouldRepaint(covariant _CleanHeartsPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.intro != intro ||
        oldDelegate.opacity != opacity;
  }
}
