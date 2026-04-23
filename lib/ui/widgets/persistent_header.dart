import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/music_player_provider.dart';
import '../../core/constants/app_config.dart';
import '../../core/utils/date_helpers.dart';
import '../theme.dart';

class PersistentHeader extends ConsumerWidget {
  const PersistentHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final daysTogether = DateHelpers.daysTogether(now);
    final musicState = ref.watch(musicPlayerProvider);
    final musicNotifier = ref.read(musicPlayerProvider.notifier);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 8, 20, 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            border: Border(
              bottom: BorderSide(color: AppColors.pastelPink.withValues(alpha: 0.1), width: 1),
            ),
          ),
          child: Row(
            children: [
              // ── Left: Greeting & Counter ──
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, Baby ❤️',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.pastelPink,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Day $daysTogether together',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.pastelPink,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Right: Mini Music Player ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.pastelPink.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (musicState.isPlaying)
                      _buildAnimatedMusicIcon()
                    else
                      const Icon(LucideIcons.music, size: 14, color: AppColors.pastelPink),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: musicNotifier.togglePlay,
                      child: Icon(
                        musicState.isPlaying ? LucideIcons.pause : LucideIcons.play,
                        size: 18,
                        color: AppColors.pastelPink,
                      ),
                    ),
                    if (musicState.isPlaying) ...[
                      const SizedBox(width: 8),
                      Text(
                        musicState.currentTitle ?? 'Playing...',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.pastelPink,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedMusicIcon() {
    return const Icon(LucideIcons.music, size: 14, color: AppColors.pastelPink)
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 600.ms)
        .tint(color: AppColors.pastelPink.withValues(alpha: 0.5));
  }
}
