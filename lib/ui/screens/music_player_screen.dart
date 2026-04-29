import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../app/music_player_provider.dart';
import '../../app/providers.dart';

class MusicPlayerScreen extends ConsumerWidget {
  const MusicPlayerScreen({super.key});

  static const _themeChoices = <Color>[
    Color(0xFF1ED760),
    Color(0xFF4EA8FF),
    Color(0xFFFF6B9F),
    Color(0xFFFFA726),
    Color(0xFFB388FF),
    Color(0xFF26C6DA),
  ];

  Future<void> _pickFiles(WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: const ['mp3', 'm4a', 'aac', 'wav', 'ogg', 'flac'],
    );
    if (result == null) return;

    final paths = result.files
        .map((f) => f.path)
        .whereType<String>()
        .where((p) => p.isNotEmpty)
        .toList();
    if (paths.isEmpty) return;

    await ref.read(musicPlayerProvider.notifier).addDeviceFiles(paths);
  }

  Color _darken(Color color, [double amount = 0.28]) {
    final hsl = HSLColor.fromColor(color);
    final next = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return next.toColor();
  }

  Future<void> _showThemePicker(
    BuildContext context,
    WidgetRef ref,
    Color current,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF171717),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Player Theme Color',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _themeChoices.map((color) {
                    final selected = color.toARGB32() == current.toARGB32();
                    return GestureDetector(
                      onTap: () {
                        ref
                            .read(musicAccentColorProvider.notifier)
                            .setColor(color);
                        Navigator.of(ctx).pop();
                      },
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: selected
                            ? const Icon(
                                LucideIcons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(musicPlayerProvider);
    final accent =
        ref.watch(musicAccentColorProvider).valueOrNull ??
        const Color(0xFF1ED760);
    final accentDark = _darken(accent);
    final notifier = ref.read(musicPlayerProvider.notifier);
    final title = state.currentTitle ?? 'No track selected';
    final artist = state.currentArtist ?? 'Add songs from your device';
    final duration = state.duration;
    final safePosition = state.position > duration ? duration : state.position;
    final maxMs = duration.inMilliseconds > 0 ? duration.inMilliseconds : 1;

    if (state.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        notifier.dismissError();
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          MediaQuery.of(context).padding.top + kToolbarHeight + 66,
          20,
          94,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF181818),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [accent, accentDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(
                          LucideIcons.music2,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: const Color(0xFFB3B3B3),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showThemePicker(context, ref, accent),
                        icon: const Icon(
                          LucideIcons.settings2,
                          color: Colors.white,
                        ),
                        tooltip: 'Player theme',
                      ),
                      IconButton(
                        onPressed: () => _pickFiles(ref),
                        icon: const Icon(
                          LucideIcons.folderPlus,
                          color: Colors.white,
                        ),
                        tooltip: 'Add songs',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      activeTrackColor: accent,
                      inactiveTrackColor: Colors.white.withValues(alpha: 0.18),
                      thumbColor: accent,
                      overlayColor: accent.withValues(alpha: 0.18),
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 7,
                      ),
                    ),
                    child: Slider(
                      min: 0,
                      max: maxMs.toDouble(),
                      value: safePosition.inMilliseconds
                          .clamp(0, maxMs)
                          .toDouble(),
                      onChanged: (value) {
                        notifier.seek(Duration(milliseconds: value.toInt()));
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _fmt(safePosition),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFFB3B3B3),
                        ),
                      ),
                      Text(
                        _fmt(duration),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFFB3B3B3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: state.playlist.isEmpty
                            ? null
                            : notifier.playPrevious,
                        icon: const Icon(
                          LucideIcons.skipBack,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: notifier.togglePlay,
                          icon: Icon(
                            state.isPlaying
                                ? LucideIcons.pause
                                : LucideIcons.play,
                            color: const Color(0xFF101010),
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: state.playlist.isEmpty
                            ? null
                            : notifier.playNext,
                        icon: const Icon(
                          LucideIcons.skipForward,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: notifier.toggleLoopMode,
                        icon: Icon(
                          LucideIcons.repeat,
                          size: 20,
                          color: state.loopMode == LoopMode.one
                              ? accent
                              : const Color(0xFF7A7A7A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: state.playlist.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF181818),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            LucideIcons.music,
                            size: 34,
                            color: Color(0xFF8A8A8A),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'No songs in your queue',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Tap folder button to add audio files from your device.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: const Color(0xFFB3B3B3)),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF181818),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: ListView.separated(
                        itemCount: state.playlist.length,
                        separatorBuilder: (_, _) => Divider(
                          color: Colors.white.withValues(alpha: 0.06),
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final track = state.playlist[index];
                          final selected = index == state.currentIndex;
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? accent.withValues(alpha: 0.14)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selected
                                    ? accent.withValues(alpha: 0.55)
                                    : Colors.transparent,
                              ),
                            ),
                            child: ListTile(
                              onTap: () => notifier.playTrackAt(index),
                              leading: Icon(
                                selected && state.isPlaying
                                    ? LucideIcons.volume2
                                    : LucideIcons.music,
                                color: selected
                                    ? accent
                                    : const Color(0xFF8A8A8A),
                              ),
                              title: Text(
                                track.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: selected
                                          ? Colors.white
                                          : const Color(0xFFD0D0D0),
                                      fontWeight: selected
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                    ),
                              ),
                              trailing: IconButton(
                                onPressed: () => notifier.removeTrackAt(index),
                                icon: Icon(
                                  LucideIcons.trash2,
                                  size: 18,
                                  color: selected
                                      ? accent.withValues(alpha: 0.75)
                                      : const Color(0xFF9A9A9A),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
