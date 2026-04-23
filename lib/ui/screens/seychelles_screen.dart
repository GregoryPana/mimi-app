import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_config.dart';
import '../theme.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/pastel_card.dart';

class SeychellesScreen extends StatefulWidget {
  const SeychellesScreen({super.key});

  @override
  State<SeychellesScreen> createState() => _SeychellesScreenState();
}

class _SeychellesScreenState extends State<SeychellesScreen> {
  late ConfettiController _confettiController;
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 10));
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      final previous = _now;
      _now = DateTime.now();

      // Check if we just hit the flight time
      final flightDone = !AppConfig.seychellesFlight.isAfter(_now);
      final wasFlightDone = !AppConfig.seychellesFlight.isAfter(previous);
      if (flightDone && !wasFlightDone) {
        _confettiController.play();
      }

      // Check if we just hit touchdown time
      final tdDone = !AppConfig.seychellesTouchdown.isAfter(_now);
      final wasTdDone = !AppConfig.seychellesTouchdown.isAfter(previous);
      if (tdDone && !wasTdDone) {
        _confettiController.play();
      }

      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Seychelles Trip'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: AnimatedGradientBackground(
        child: Stack(
          children: [
            Positioned.fill(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.of(context).padding.top + kToolbarHeight + 20,
                  20,
                  40,
                ),
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: AppColors.appBackground,
                      image: const DecorationImage(
                        image: AssetImage('assets/images/seychelles/seychelles_beach.jpg'),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.pastelPink.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Container(color: Colors.black.withValues(alpha: 0.2)),
                        const Center(child: Icon(LucideIcons.planeTakeoff, size: 64, color: Colors.white)),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1),
                  const SizedBox(height: 32),
                  
                  _buildCountdownCard(
                    context: context,
                    title: 'Time to Flight',
                    target: AppConfig.seychellesFlight,
                    icon: LucideIcons.plane,
                    gradient: const LinearGradient(colors: [AppColors.pastelPink, AppColors.pastelPeach]),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                  
                  const SizedBox(height: 24),
                  
                  _buildCountdownCard(
                    context: context,
                    title: 'Touchdown in Seychelles',
                    target: AppConfig.seychellesTouchdown,
                    icon: LucideIcons.mapPin,
                    gradient: const LinearGradient(colors: [AppColors.pastelBlue, AppColors.pastelLavender]),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  AppColors.pastelPink,
                  AppColors.pastelBlue,
                  AppColors.pastelPeach,
                  AppColors.pastelLavender,
                  AppColors.pastelMint,
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'seychelles_party_fab',
        backgroundColor: AppColors.pastelPink,
        onPressed: () { _confettiController.play(); },
        child: const Icon(LucideIcons.partyPopper, color: Colors.white),
      ),
    );
  }

  Widget _buildCountdownCard({
    required BuildContext context,
    required String title,
    required DateTime target,
    required IconData icon,
    required Gradient gradient,
  }) {
    final remaining = target.difference(_now);
    final isDone = remaining.isNegative;

    return PastelCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (isDone)
            Center(
              child: Text(
                'We made it! 🎉',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.pastelPink,
                ),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimeUnit(context, remaining.inDays.toString().padLeft(2, '0'), 'Days'),
                _buildTimeUnit(context, (remaining.inHours % 24).toString().padLeft(2, '0'), 'Hrs'),
                _buildTimeUnit(context, (remaining.inMinutes % 60).toString().padLeft(2, '0'), 'Min'),
                _buildTimeUnit(context, (remaining.inSeconds % 60).toString().padLeft(2, '0'), 'Sec'),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(BuildContext context, String value, String label) {
    return Column(
      children: [
        _SplitFlapDigit(
          value: value,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
        ),
        const SizedBox(height: 8),
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
              ),
        ),
      ],
    );
  }
}

class _SplitFlapDigit extends StatefulWidget {
  final String value;
  final TextStyle style;

  const _SplitFlapDigit({required this.value, required this.style});

  @override
  State<_SplitFlapDigit> createState() => _SplitFlapDigitState();
}

class _SplitFlapDigitState extends State<_SplitFlapDigit> with SingleTickerProviderStateMixin {
  late String _currentValue;
  late String _nextValue;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
    _nextValue = widget.value;
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _currentValue = _nextValue);
        _controller.reset();
      }
    });
  }

  @override
  void didUpdateWidget(_SplitFlapDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _nextValue = widget.value;
      _controller.forward(from: 0);
    }
  }

  Widget _buildHalf(String val, Alignment alignment) {
    return ClipRect(
      child: Align(
        alignment: alignment,
        heightFactor: 0.5,
        child: Container(
          width: 60,
          height: 64, // The full size of the container before clipping
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(val, style: widget.style),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.pastelPink.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final val = _animation.value;
          final isFirstHalf = val < 0.5;

          return Stack(
            children: [
              // Background: Top half is always NEXT
              Positioned(
                top: 0,
                child: _buildHalf(_nextValue, Alignment.topCenter),
              ),
              // Background: Bottom half is always CURRENT
              Positioned(
                bottom: 0,
                child: _buildHalf(_currentValue, Alignment.bottomCenter),
              ),
              
              // Animated Flapper Top -> Bottom
              if (isFirstHalf)
                Positioned(
                  top: 0,
                  child: Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.003)
                      ..rotateX(val * math.pi), // 0 to pi/2 around the bottom edge
                    alignment: Alignment.bottomCenter,
                    child: _buildHalf(_currentValue, Alignment.topCenter),
                  ),
                )
              else
                Positioned(
                  bottom: 0,
                  // Rotates from back (-pi/2) to front (0)
                  child: Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.003)
                      ..rotateX(-(1 - val) * math.pi), 
                    alignment: Alignment.topCenter,
                    child: _buildHalf(_nextValue, Alignment.bottomCenter),
                  ),
                ),
              
              // Shadow/Gradient Overlay on the bottom half as the flap comes down
              if (!isFirstHalf)
                Positioned(
                  bottom: 0,
                  child: Opacity(
                    opacity: (1 - val) * 0.5,
                    child: Container(
                      width: 60,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
                      ),
                    ),
                  ),
                ),

              // The mechanical seam in the middle
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: 1,
                  color: Colors.black.withValues(alpha: 0.15),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
