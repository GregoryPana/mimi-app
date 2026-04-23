import 'package:flutter/material.dart';

import '../theme.dart';

/// Mood selector bar showing emoji buttons.
/// Displayed at the bottom of the home screen.
class MoodSelector extends StatelessWidget {
  const MoodSelector({super.key, this.onMoodSelected});

  final void Function(String mood)? onMoodSelected;

  static const _moods = [
    _MoodOption('happy', '😊'),
    _MoodOption('missing', '😢'),
    _MoodOption('romantic', '😍'),
    _MoodOption('calm', '😌'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.pastelLavender.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite, size: 16, color: AppColors.pastelPink),
                    const SizedBox(width: 6),
                    Text(
                      'How are you feeling today?',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'We\'ll show you something special',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: _moods.map((mood) {
              return GestureDetector(
                onTap: () => onMoodSelected?.call(mood.id),
                child: Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(left: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(mood.emoji, style: const TextStyle(fontSize: 20)),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _MoodOption {
  const _MoodOption(this.id, this.emoji);
  final String id;
  final String emoji;
}
