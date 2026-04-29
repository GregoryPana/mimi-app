import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(() => player.dispose());
  return player;
});

final musicPlayerProvider =
    StateNotifierProvider<MusicPlayerNotifier, MusicPlayerState>((ref) {
      return MusicPlayerNotifier(ref.watch(audioPlayerProvider));
    });

class MusicTrack {
  const MusicTrack({required this.path, required this.title});

  final String path;
  final String title;

  Map<String, dynamic> toJson() => {'path': path, 'title': title};
  factory MusicTrack.fromJson(Map<String, dynamic> json) =>
      MusicTrack(path: json['path'] as String, title: json['title'] as String);
}

const _kUnset = Object();

class MusicPlayerState {
  final bool isPlaying;
  final String? currentTitle;
  final String? currentArtist;
  final Duration position;
  final Duration duration;
  final LoopMode loopMode;
  final List<MusicTrack> playlist;
  final int currentIndex;
  final String? errorMessage;

  MusicPlayerState({
    this.isPlaying = false,
    this.currentTitle,
    this.currentArtist,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.loopMode = LoopMode.off,
    this.playlist = const [],
    this.currentIndex = -1,
    this.errorMessage,
  });

  MusicTrack? get currentTrack {
    if (currentIndex < 0 || currentIndex >= playlist.length) return null;
    return playlist[currentIndex];
  }

  MusicPlayerState copyWith({
    bool? isPlaying,
    Object? currentTitle = _kUnset,
    Object? currentArtist = _kUnset,
    Duration? position,
    Duration? duration,
    LoopMode? loopMode,
    List<MusicTrack>? playlist,
    int? currentIndex,
    Object? errorMessage = _kUnset,
  }) {
    return MusicPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      currentTitle: identical(currentTitle, _kUnset)
          ? this.currentTitle
          : currentTitle as String?,
      currentArtist: identical(currentArtist, _kUnset)
          ? this.currentArtist
          : currentArtist as String?,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      loopMode: loopMode ?? this.loopMode,
      playlist: playlist ?? this.playlist,
      currentIndex: currentIndex ?? this.currentIndex,
      errorMessage: identical(errorMessage, _kUnset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class MusicPlayerNotifier extends StateNotifier<MusicPlayerState> {
  MusicPlayerNotifier(this._player) : super(MusicPlayerState()) {
    _player.playerStateStream.listen((playerState) {
      state = state.copyWith(isPlaying: playerState.playing);
      if (playerState.processingState == ProcessingState.completed) {
        playNext();
      }
    });

    _player.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
    });

    _player.durationStream.listen((dur) {
      state = state.copyWith(duration: dur ?? Duration.zero);
    });

    _player.loopModeStream.listen((mode) {
      state = state.copyWith(loopMode: mode);
    });

    _loadPersisted();
  }

  final AudioPlayer _player;

  static const _kPlaylistKey = 'music_playlist';
  static const _kIndexKey = 'music_current_index';

  Future<void> _loadPersisted() async {
    final prefs = await SharedPreferences.getInstance();
    final playlistRaw = prefs.getStringList(_kPlaylistKey);
    final index = prefs.getInt(_kIndexKey) ?? -1;

    if (playlistRaw != null && playlistRaw.isNotEmpty) {
      final playlist = playlistRaw.map((s) {
        final parts = s.split('|');
        return MusicTrack(path: parts[0], title: parts[1]);
      }).toList();

      state = state.copyWith(playlist: playlist, currentIndex: index);

      // Load the track but don't autoplay on startup
      if (index >= 0 && index < playlist.length) {
        await _loadCurrentAndMaybePlay(autoplay: false);
      }
    }
  }

  Future<void> _savePersisted() async {
    final prefs = await SharedPreferences.getInstance();
    final playlistRaw =
        state.playlist.map((t) => '${t.path}|${t.title}').toList();
    await prefs.setStringList(_kPlaylistKey, playlistRaw);
    await prefs.setInt(_kIndexKey, state.currentIndex);
  }

  String _titleFromPath(String path) {
    final leaf = path.split(RegExp(r'[\\/]')).last;
    final dot = leaf.lastIndexOf('.');
    if (dot <= 0) return leaf;
    return leaf.substring(0, dot);
  }

  Future<void> _loadCurrentAndMaybePlay({bool autoplay = true}) async {
    var queue = List<MusicTrack>.from(state.playlist);
    if (queue.isEmpty) {
      await _player.stop();
      state = state.copyWith(
        playlist: const [],
        currentIndex: -1,
        currentTitle: null,
        currentArtist: null,
        duration: Duration.zero,
        position: Duration.zero,
        isPlaying: false,
      );
      return;
    }

    var index = state.currentIndex;
    if (index < 0 || index >= queue.length) index = 0;

    while (queue.isNotEmpty) {
      final track = queue[index];
      final exists = await File(track.path).exists();
      if (!exists) {
        queue.removeAt(index);
        if (index >= queue.length) index = 0;
        state = state.copyWith(
          playlist: queue,
          currentIndex: queue.isEmpty ? -1 : index,
          errorMessage:
              'Could not find "${track.title}". It was removed from your queue.',
        );
        continue;
      }

      try {
        await _player.setFilePath(track.path);
        if (autoplay) {
          await _player.play();
        }
        state = state.copyWith(
          playlist: queue,
          currentIndex: index,
          currentTitle: track.title,
          currentArtist: 'From your device',
          position: Duration.zero,
          errorMessage: null,
        );
        _savePersisted();
        return;
      } catch (_) {
        queue.removeAt(index);
        if (index >= queue.length) index = 0;
        state = state.copyWith(
          playlist: queue,
          currentIndex: queue.isEmpty ? -1 : index,
          errorMessage:
              'Could not open "${track.title}". It was removed from your queue.',
        );
      }
    }

    await _player.stop();
    state = state.copyWith(
      playlist: const [],
      currentIndex: -1,
      currentTitle: null,
      currentArtist: null,
      position: Duration.zero,
      duration: Duration.zero,
      isPlaying: false,
    );
  }

  Future<void> addDeviceFiles(List<String> paths) async {
    if (paths.isEmpty) return;

    final existing = state.playlist.map((t) => t.path).toSet();
    final incoming = paths
        .where((p) => p.isNotEmpty && !existing.contains(p))
        .map((p) => MusicTrack(path: p, title: _titleFromPath(p)))
        .toList();
    if (incoming.isEmpty) return;

    final updated = [...state.playlist, ...incoming];
    final startIndex = state.currentIndex == -1 ? 0 : state.currentIndex;
    state = state.copyWith(
      playlist: updated,
      currentIndex: startIndex,
      errorMessage: null,
    );
    _savePersisted();

    if (state.currentTitle == null) {
      await _loadCurrentAndMaybePlay(autoplay: true);
    }
  }

  Future<void> playTrackAt(int index) async {
    if (index < 0 || index >= state.playlist.length) return;
    state = state.copyWith(currentIndex: index, errorMessage: null);
    _savePersisted();
    await _loadCurrentAndMaybePlay(autoplay: true);
  }

  Future<void> playAsset(
    String assetPath, {
    String? title,
    String? artist,
  }) async {
    try {
      await _player.setAsset(assetPath);
      state = state.copyWith(
        currentTitle: title,
        currentArtist: artist,
        errorMessage: null,
      );
      await _player.play();
    } catch (_) {
      state = state.copyWith(errorMessage: 'Could not play this audio source.');
    }
  }

  void togglePlay() {
    if (state.currentTrack != null) {
      if (_player.playing) {
        _player.pause();
      } else {
        _player.play();
      }
      return;
    }

    if (state.currentTitle == null && state.playlist.isEmpty) {
      playOurSong();
      return;
    }

    _loadCurrentAndMaybePlay(autoplay: true);
  }

  Future<void> playOurSong() async {
    await playAsset(
      'assets/audio/our_song.mp3',
      title: 'Our Song',
      artist: 'Mimi Girl & Mimi Boy',
    );
  }

  Future<void> playNext() async {
    final len = state.playlist.length;
    if (len == 0) return;
    final next = state.currentIndex < 0 ? 0 : (state.currentIndex + 1) % len;
    state = state.copyWith(currentIndex: next);
    await _loadCurrentAndMaybePlay(autoplay: true);
  }

  Future<void> playPrevious() async {
    final len = state.playlist.length;
    if (len == 0) return;
    if (state.position > const Duration(seconds: 3)) {
      seek(Duration.zero);
      return;
    }
    final prev = state.currentIndex <= 0 ? len - 1 : state.currentIndex - 1;
    state = state.copyWith(currentIndex: prev);
    await _loadCurrentAndMaybePlay(autoplay: true);
  }

  void seek(Duration position) {
    _player.seek(position);
  }

  Future<void> toggleLoopMode() async {
    final next = state.loopMode == LoopMode.one ? LoopMode.off : LoopMode.one;
    await _player.setLoopMode(next);
    state = state.copyWith(loopMode: next);
  }

  void dismissError() {
    if (state.errorMessage == null) return;
    state = state.copyWith(errorMessage: null);
  }

  void removeTrackAt(int index) {
    if (index < 0 || index >= state.playlist.length) return;
    final removedCurrent = index == state.currentIndex;
    final updated = [...state.playlist]..removeAt(index);

    if (updated.isEmpty) {
      stop();
      state = state.copyWith(
        playlist: const [],
        currentIndex: -1,
        currentTitle: null,
        currentArtist: null,
        errorMessage: null,
      );
      return;
    }

    var nextIndex = state.currentIndex;
    if (index < nextIndex) {
      nextIndex -= 1;
    }
    if (nextIndex >= updated.length) nextIndex = 0;

    state = state.copyWith(playlist: updated, currentIndex: nextIndex);
    _savePersisted();
    if (removedCurrent) {
      _loadCurrentAndMaybePlay(autoplay: state.isPlaying);
    }
  }

  void stop() {
    _player.stop();
  }
}
