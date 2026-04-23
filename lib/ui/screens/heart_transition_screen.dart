import 'package:flutter/material.dart';

import '../navigation/app_shell.dart';

class HeartTransitionScreen extends StatefulWidget {
  const HeartTransitionScreen({super.key});

  @override
  State<HeartTransitionScreen> createState() => _HeartTransitionScreenState();
}

class _HeartTransitionScreenState extends State<HeartTransitionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2300),
    );

    _controller.forward().whenComplete(() {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AppShell()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          const riseEnd = 0.435;
          const glowHoldEnd = 0.652;

          final slideY = t < riseEnd
              ? 0.5 - (0.5 * (t / riseEnd))
              : 0.0;

          final glowStrength = t < riseEnd
              ? t / riseEnd
              : t < glowHoldEnd
                  ? 1.0
                  : (1 - (t - glowHoldEnd) / (1 - glowHoldEnd)).clamp(0.0, 1.0);

          final opacity = t < glowHoldEnd
              ? 1.0
              : (1 - (t - glowHoldEnd) / (1 - glowHoldEnd)).clamp(0.0, 1.0);

          final scale = 0.9 + (0.15 * glowStrength);

          return Opacity(
            opacity: opacity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: glowStrength.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          radius: 0.9,
                          colors: [
                            const Color(0xFFFF1744).withValues(alpha: 0.6),
                            const Color(0xFFB00020).withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(0, slideY),
                  child: Transform.scale(
                    scale: scale,
                    child: CustomPaint(
                      size: const Size(150, 150),
                      painter: _HeartPainter(glowStrength: glowStrength),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeartPainter extends CustomPainter {
  _HeartPainter({required this.glowStrength});

  final double glowStrength;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final path = _heartPath(center, size.width * 0.5);

    final glowPaint = Paint()
      ..color = Color.lerp(const Color(0xFFB00020), const Color(0xFFFF1744), glowStrength)!
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 30 * glowStrength);

    final fillPaint = Paint()
      ..color = const Color(0xFFFF1744)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, fillPaint);
  }

  Path _heartPath(Offset center, double size) {
    final width = size;
    final height = size * 0.95;
    final x = center.dx;
    final y = center.dy;

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
  bool shouldRepaint(covariant _HeartPainter oldDelegate) {
    return oldDelegate.glowStrength != glowStrength;
  }
}
