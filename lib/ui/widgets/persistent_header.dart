import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../app/music_player_provider.dart';
import '../../app/providers.dart';
import '../../core/utils/date_helpers.dart';
import '../theme.dart';

class PersistentHeader extends ConsumerWidget {
  const PersistentHeader({super.key, this.isDarkMode = false});

  final bool isDarkMode;

  Color _darken(Color color, [double amount = 0.28]) {
    final hsl = HSLColor.fromColor(color);
    final next = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return next.toColor();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final daysTogether = DateHelpers.daysTogether(now);
    final musicState = ref.watch(musicPlayerProvider);
    final accent =
        ref.watch(musicAccentColorProvider).valueOrNull ??
        const Color(0xFF1ED760);
    final accentDark = _darken(accent);
    final musicNotifier = ref.read(musicPlayerProvider.notifier);
    final hasTrack = musicState.currentTitle != null;
    final headerBg = isDarkMode
        ? const Color(0xFF0F0F0F).withValues(alpha: 0.88)
        : Colors.white.withValues(alpha: 0.7);
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.pastelPink.withValues(alpha: 0.1);
    final titleColor = isDarkMode ? Colors.white : AppColors.textPrimary;
    final dayColor = isDarkMode ? accent : AppColors.pastelPink;
    final miniPlayerBg = Color.lerp(const Color(0xFF121212), accent, 0.12)!;
    final miniPlayerBorder = accent.withValues(alpha: 0.26);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            20,
            MediaQuery.of(context).padding.top + 8,
            20,
            14,
          ),
          decoration: BoxDecoration(
            color: headerBg,
            border: Border(bottom: BorderSide(color: borderColor, width: 1)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 390;
              final title = musicState.currentTitle ?? 'Our Song';
              final subtitle =
                  musicState.currentArtist ?? 'Mimi Girl & Mimi Boy';
              final durationMs = musicState.duration.inMilliseconds;
              final positionMs = musicState.position.inMilliseconds;
              final progress = durationMs <= 0
                  ? 0.0
                  : (positionMs / durationMs).clamp(0.0, 1.0);

              return Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, Baby ❤️',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: titleColor,
                                letterSpacing: -0.5,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: dayColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Day $daysTogether together',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: dayColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: compact ? 150 : 188,
                    padding: const EdgeInsets.fromLTRB(9, 8, 8, 8),
                    decoration: BoxDecoration(
                      color: miniPlayerBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: miniPlayerBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.14),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: accent.withValues(alpha: 0.12),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            gradient: LinearGradient(
                              colors: [accent, accentDark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Icon(
                            LucideIcons.music2,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: accent.withValues(alpha: 0.78),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(99),
                                child: LinearProgressIndicator(
                                  value: hasTrack ? progress : 0,
                                  minHeight: 3,
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.2,
                                  ),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    accent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: musicNotifier.togglePlay,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: accent,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              musicState.isPlaying
                                  ? LucideIcons.pause
                                  : LucideIcons.play,
                              size: 14,
                              color: const Color(0xFF111111),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
