import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_config.dart';
import '../theme.dart';
import '../widgets/animated_gradient_background.dart';
import 'heart_transition_screen.dart';

class PasscodeScreen extends StatefulWidget {
  const PasscodeScreen({super.key});

  @override
  State<PasscodeScreen> createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends State<PasscodeScreen> {
  static const _passcode = AppConfig.passcode;
  static final _passcodeLength = _passcode.length;
  final List<int> _digits = [];
  String? _error;

  void _addDigit(int digit) {
    if (_digits.length >= _passcodeLength) return;
    
    HapticFeedback.lightImpact();
    setState(() {
      _digits.add(digit);
      _error = null;
    });

    if (_digits.length == _passcodeLength) {
      final entered = _digits.join();
      if (entered == _passcode) {
        HapticFeedback.mediumImpact();
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const HeartTransitionScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      } else {
        HapticFeedback.heavyImpact();
        setState(() => _error = AppConfig.passcodeError);
        Timer(const Duration(milliseconds: 700), () {
          if (!mounted) return;
          setState(() {
            _digits.clear();
          });
        });
      }
    }
  }

  void _removeDigit() {
    if (_digits.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _digits.removeLast();
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                
                // Header section
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(LucideIcons.lock, size: 32, color: AppColors.pastelLavender),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome back, Mimi',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error ?? AppConfig.passcodeHint,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _error != null ? Colors.redAccent : AppColors.textSecondary,
                        fontWeight: _error != null ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 48),
                
                // Dots Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_passcodeLength, (index) {
                    final filled = index < _digits.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: filled ? AppColors.pastelLavender : Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        boxShadow: filled ? [
                          BoxShadow(
                            color: AppColors.pastelLavender.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          )
                        ] : [],
                        border: Border.all(
                          color: filled ? AppColors.pastelLavender : Colors.white.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                    );
                  }),
                ),
                
                const Spacer(flex: 3),
                
                // Keypad
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Column(
                    children: [
                      _buildKeyRow([1, 2, 3]),
                      const SizedBox(height: 20),
                      _buildKeyRow([4, 5, 6]),
                      const SizedBox(height: 20),
                      _buildKeyRow([7, 8, 9]),
                      const SizedBox(height: 20),
                      _buildLastRow(),
                    ],
                  ),
                ),
                
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeyRow(List<int> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: numbers.map((n) => _KeyButton(
        label: n.toString(),
        onPressed: () => _addDigit(n),
      )).toList(),
    );
  }

  Widget _buildLastRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 70, height: 70), // Spacer
        _KeyButton(
          label: '0',
          onPressed: () => _addDigit(0),
        ),
        _KeyButton(
          icon: LucideIcons.delete,
          onPressed: _removeDigit,
          isAction: true,
        ),
      ],
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({
    this.label,
    this.icon,
    required this.onPressed,
    this.isAction = false,
  });

  final String? label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          splashColor: AppColors.pastelLavender.withValues(alpha: 0.2),
          child: Center(
            child: icon != null
                ? Icon(icon, color: Colors.white, size: 28)
                : Text(
                    label!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
