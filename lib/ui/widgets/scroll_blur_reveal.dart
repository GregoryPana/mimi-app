import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

class ScrollBlurReveal extends StatefulWidget {
  const ScrollBlurReveal({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 360),
    this.maxBlur = 8,
    this.maxOffsetY = 12,
    this.minOpacity = 0.5,
  });

  final Widget child;
  final Duration duration;
  final double maxBlur;
  final double maxOffsetY;
  final double minOpacity;

  @override
  State<ScrollBlurReveal> createState() => _ScrollBlurRevealState();
}

class _ScrollBlurRevealState extends State<ScrollBlurReveal> {
  ScrollPosition? _position;
  double _target = 0;
  bool _retryScheduled = false;
  bool _lockedRevealed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = Scrollable.maybeOf(context)?.position;
    if (_position == next) {
      return;
    }
    _position?.removeListener(_handleScroll);
    _position = next;
    if (_position == null) {
      if (_target != 1) {
        setState(() => _target = 1);
      }
      return;
    }
    _position?.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleScroll());
    Future<void>.delayed(const Duration(milliseconds: 60), () {
      if (mounted) _handleScroll();
    });
  }

  void _handleScroll() {
    if (!mounted) return;
    if (_lockedRevealed) return;
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox ||
        !renderObject.hasSize ||
        !renderObject.attached) {
      if (!_retryScheduled) {
        _retryScheduled = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _retryScheduled = false;
          if (mounted) _handleScroll();
        });
      }
      return;
    }

    final viewportHeight = MediaQuery.sizeOf(context).height;
    final top = renderObject.localToGlobal(Offset.zero).dy;
    final bottom = top + renderObject.size.height;
    final visible = math.max(
      0.0,
      math.min(bottom, viewportHeight) - math.max(top, 0),
    );
    final visibleFraction = (visible / renderObject.size.height).clamp(
      0.0,
      1.0,
    );

    final nextTarget = Curves.easeOutCubic.transform(
      ((visibleFraction - 0.02) / 0.5).clamp(0.0, 1.0),
    );
    final resolvedTarget = nextTarget > _target ? nextTarget : _target;
    if ((resolvedTarget - _target).abs() > 0.01) {
      setState(() => _target = resolvedTarget);
    }

    if (_target >= 0.995) {
      _lockedRevealed = true;
      _position?.removeListener(_handleScroll);
    }
  }

  @override
  void dispose() {
    _position?.removeListener(_handleScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: _target),
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      child: widget.child,
      builder: (context, value, child) {
        final sigma = (1 - value) * widget.maxBlur;
        final offsetY = (1 - value) * widget.maxOffsetY;
        final opacity = widget.minOpacity + (value * (1 - widget.minOpacity));
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, offsetY),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
