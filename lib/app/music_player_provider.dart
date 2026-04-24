import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(() => player.dispose());
  return player;
});

final musicPlayerProvider = StateNotifierProvider<MusicPlayerNotifier, MusicPlayerState>((ref) {
  return MusicPlayerNotifier(ref.watch(audioPlayerProvider));
});

class MusicPlayerState {
  final bool isPlaying;
  final String? currentTitle;
  final String? currentArtist;
  final Duration position;
  final Duration duration;
  final LoopMode loopMode;

  MusicPlayerState({
    this.isPlaying = false,
    this.currentTitle,
    this.currentArtist,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.loopMode = LoopMode.off,
  });

  MusicPlayerState copyWith({
    bool? isPlaying,
    String? currentTitle,
    String? currentArtist,
    Duration? position,
    Duration? duration,
    LoopMode? loopMode,
  }) {
    return MusicPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      currentTitle: currentTitle ?? this.currentTitle,
      currentArtist: currentArtist ?? this.currentArtist,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      loopMode: loopMode ?? this.loopMode,
    );
  }
}

class MusicPlayerNotifier extends StateNotifier<MusicPlayerState> {
  final AudioPlayer _player;

  MusicPlayerNotifier(this._player) : super(MusicPlayerState()) {
    _player.playerStateStream.listen((state) {
      this.state = this.state.copyWith(isPlaying: state.playing);
    });

    _player.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
    });

    _player.durationStream.listen((dur) {
      state = state.copyWith(duration: dur ?? Duration.zero);
    });
  }

  Future<void> playAsset(String assetPath, {String? title, String? artist}) async {
    try {
      await _player.setAsset(assetPath);
      state = state.copyWith(currentTitle: title, currentArtist: artist);
      _player.play();
    } catch (e) {
      // Handle error
    }
  }

  void togglePlay() {
    if (state.currentTitle == null) {
      // Play default if nothing is loaded
      playOurSong();
      return;
    }
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  Future<void> playOurSong() async {
    await playAsset('assets/audio/our_song.mp3', title: 'Our Song', artist: 'Mimi Girl & Mimi Boy');
  }

  void seek(Duration position) {
    _player.seek(position);
  }

  void stop() {
    _player.stop();
  }
}
