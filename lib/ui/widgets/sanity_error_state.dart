import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../theme.dart';

String sanityErrorMessage(Object error) {
  final text = error.toString().toLowerCase();
  if (error is SocketException || text.contains('socketexception')) {
    return 'No internet connection. Please check network and try again.';
  }
  if (text.contains('failed host lookup') ||
      text.contains('no address associated')) {
    return 'Service is unreachable right now. Please try again in a moment.';
  }
  if (text.contains('timeout')) {
    return 'The request timed out. Please try again.';
  }
  if (text.contains('401') || text.contains('403')) {
    return 'Access to cloud data is unavailable right now.';
  }
  if (text.contains('400')) {
    return 'The request to the cloud was invalid. Please check data.';
  }
  if (text.contains('500') || text.contains('502') || text.contains('503')) {
    return 'Cloud service is having trouble. Please retry shortly.';
  }
  return 'Could not connect to cloud data ($error). Please try again.';
}

class SanityErrorState extends StatelessWidget {
  const SanityErrorState({
    super.key,
    required this.title,
    this.error,
    this.onRetry,
    this.dark = false,
  });

  final String title;
  final Object? error;
  final VoidCallback? onRetry;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final iconSize = compact ? 24.0 : 30.0;
        final horizontalPadding = compact ? 14.0 : 18.0;
        final verticalPadding = compact ? 14.0 : 18.0;

        final bgColor = dark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.92);
        final borderColor = dark
            ? Colors.white.withValues(alpha: 0.16)
            : AppColors.border;
        final titleColor = dark ? Colors.white : AppColors.textPrimary;
        final bodyColor = dark ? Colors.white70 : AppColors.textSecondary;
        final iconColor = dark ? Colors.white70 : AppColors.textMuted;
        final buttonColor = dark
            ? const Color(0xFF14A8A4)
            : AppColors.pastelPink;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.wifiOff, color: iconColor, size: iconSize),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: compact ? 15 : 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    sanityErrorMessage(error ?? Exception('unknown')),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: bodyColor,
                      fontSize: compact ? 12 : 13,
                      height: 1.4,
                    ),
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          horizontal: compact ? 14 : 16,
                          vertical: compact ? 9 : 10,
                        ),
                      ),
                      icon: const Icon(LucideIcons.refreshCcw, size: 14),
                      label: const Text('Retry'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
