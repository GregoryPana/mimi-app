import 'dart:math' as math;
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
      duration: const Duration(milliseconds: 3200),
    );

    _controller.forward().whenComplete(() {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const AppShell(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
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
          
          // Easing curves
          final curve = Curves.easeInOutCubic.transform(t.clamp(0.0, 0.45) / 0.45);
          final fadeOut = Curves.easeIn.transform(((t - 0.85) / 0.15).clamp(0.0, 1.0));

          // Rise animation
          final slideY = 0.5 * (1.0 - curve);
          
          // Heartbeat pulse (sinusoidal)
          double pulse = 0.0;
          double shake = 0.0;
          if (t > 0.35) {
            final wave = math.sin((t - 0.35) * 24);
            pulse = wave.clamp(0, 1) * 0.045 * (1.0 - fadeOut);
            shake = wave * 1.2 * (1.0 - fadeOut);
          }

          // Glow and Scale
          final glowStrength = math.sin(t * 12).abs() * 0.4 + 0.6;
          final scale = (0.75 + (0.25 * curve) + pulse) * (1.0 - (fadeOut * 0.3));
          final opacity = 1.0 - fadeOut;

          return Stack(
            children: [
              // Background Glow
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      radius: 1.5,
                      colors: [
                        const Color(0xFFFF1744).withValues(alpha: 0.12 * curve * glowStrength),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Particles
              if (t > 0.1)
                ...List.generate(15, (i) {
                  final pT = (t - 0.1 + (i * 0.05)) % 1.0;
                  final pOpacity = math.sin(pT * math.pi) * 0.3;
                  return Positioned(
                    left: (math.sin(i * 1.5) * 0.4 + 0.5) * MediaQuery.of(context).size.width,
                    top: (0.8 - pT * 0.6) * MediaQuery.of(context).size.height,
                    child: Opacity(
                      opacity: pOpacity * opacity,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF8A80),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Color(0xFFFF1744), blurRadius: 4),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              
              // The Heart
              Center(
                child: Transform.translate(
                  offset: Offset(shake, (slideY * MediaQuery.of(context).size.height - 100) + shake),
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      child: CustomPaint(
                        size: const Size(200, 200),
                        painter: _HeartPainter(
                          progress: t,
                          glowStrength: glowStrength,
                          isRising: t < 0.45,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Final Flash
              if (t > 0.9)
                Positioned.fill(
                  child: Opacity(
                    opacity: ((t - 0.9) / 0.1).clamp(0, 1),
                    child: Container(color: Colors.white),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _HeartPainter extends CustomPainter {
  _HeartPainter({
    required this.progress,
    required this.glowStrength,
    required this.isRising,
  });

  final double progress;
  final double glowStrength;
  final bool isRising;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final width = size.width * 0.45;
    final path = _heartPath(center, width);

    // 1. Deep outer glow (Bloom)
    final bloomPaint = Paint()
      ..color = const Color(0xFFFF1744).withValues(alpha: 0.3 * glowStrength)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 45 * glowStrength);
    canvas.drawPath(path, bloomPaint);

    // 2. Secondary glow
    final secondaryGlow = Paint()
      ..color = const Color(0xFFB00020).withValues(alpha: 0.5)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawPath(path, secondaryGlow);

    // 3. Main Body (Gradient)
    final mainPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFFF5252),
          const Color(0xFFD50000),
          const Color(0xFFB00020),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, mainPaint);

    // 4. Inner "Glass" highlight
    final highlightPath = _heartPath(center.translate(-2, -4), width * 0.85);
    final highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.25),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.5))
      ..style = PaintingStyle.fill;
    
    canvas.save();
    canvas.clipPath(path);
    canvas.drawPath(highlightPath, highlightPaint);
    canvas.restore();

    // 5. Specular highlight (the tiny dot)
    final specularPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center.translate(-width * 0.3, -width * 0.3), width * 0.1, specularPaint);
  }

  Path _heartPath(Offset center, double size) {
    final width = size * 2.0;
    final height = width * 0.9;
    final x = center.dx;
    final y = center.dy - height * 0.3;

    final path = Path();
    path.moveTo(x, y + height * 0.3);
    
    // Right side
    path.cubicTo(
      x + width * 0.5, y, 
      x + width * 0.9, y + height * 0.5, 
      x, y + height
    );
    
    // Left side
    path.cubicTo(
      x - width * 0.9, y + height * 0.5, 
      x - width * 0.5, y, 
      x, y + height * 0.3
    );
    
    return path;
  }

  @override
  bool shouldRepaint(covariant _HeartPainter oldDelegate) {
    return true;
  }
}
