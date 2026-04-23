import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme.dart';

/// Mood selector bar showing emoji buttons.
/// Displayed at the bottom of the home screen.
class MoodSelector extends StatefulWidget {
  const MoodSelector({super.key, this.onMoodSelected});

  final void Function(String mood)? onMoodSelected;

  @override
  State<MoodSelector> createState() => _MoodSelectorState();
}

class _MoodSelectorState extends State<MoodSelector> {
  String? _selectedMoodId;

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite, size: 16, color: AppColors.pastelPink),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'How are you feeling today?',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _moods.map((mood) {
              final isSelected = _selectedMoodId == mood.id;
              
              Widget emojiCircle = Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.pastelPink : Colors.white.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isSelected ? AppColors.pastelPink.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.05),
                      blurRadius: isSelected ? 12 : 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(mood.emoji, style: const TextStyle(fontSize: 22)),
                ),
              );
              
              if (isSelected) {
                emojiCircle = emojiCircle.animate(key: ValueKey(mood.id)).scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.1, 1.1),
                  curve: Curves.elasticOut,
                  duration: 600.ms,
                );
              }

              return Flexible(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _selectedMoodId = mood.id);
                    widget.onMoodSelected?.call(mood.id);
                  },
                  child: emojiCircle,
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
