import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_config.dart';
import '../theme.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/pastel_card.dart';
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
    setState(() {
      _digits.add(digit);
      _error = null;
    });
    if (_digits.length == _passcodeLength) {
      final entered = _digits.join();
      if (entered == _passcode) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HeartTransitionScreen()),
        );
      } else {
        setState(() => _error = AppConfig.passcodeError);
        Timer(const Duration(milliseconds: 700), () {
          if (!mounted) return;
          setState(() => _digits.clear());
        });
      }
    }
  }

  void _removeDigit() {
    if (_digits.isEmpty) return;
    setState(() {
      _digits.removeLast();
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome back, Mimi', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(AppConfig.passcodeHint, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 24),
                PastelCard(
                  child: Column(
                    children: [
                      Text('Enter passcode', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_passcodeLength, (index) {
                          final filled = index < _digits.length;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: filled ? AppColors.pastelLavender : AppColors.divider,
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _error!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: 12,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                    ),
                    itemBuilder: (context, index) {
                      if (index == 9) {
                        return const SizedBox.shrink();
                      }
                      if (index == 11) {
                        return _KeyButton(
                          icon: LucideIcons.delete,
                          onPressed: _removeDigit,
                        );
                      }
                      final number = index == 10 ? 0 : index + 1;
                      return _KeyButton(
                        label: number.toString(),
                        onPressed: () => _addDigit(number),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({this.label, this.icon, required this.onPressed});

  final String? label;
  final IconData? icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onPressed,
        child: Center(
          child: icon != null
              ? Icon(icon, color: AppColors.textPrimary)
              : Text(
                  label!,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
        ),
      ),
    );
  }
}
