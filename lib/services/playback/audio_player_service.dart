import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();
  
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<bool> get playingStream => _player.playingStream;
  
  Stream<PlaybackState> get playbackStateStream => Rx.combineLatest3<Duration, Duration?, PlayerState, PlaybackState>(
    positionStream,
    durationStream,
    playerStateStream,
    (position, duration, playerState) => PlaybackState(
      position: position,
      duration: duration ?? Duration.zero,
      isPlaying: playerState.playing,
      isBuffering: playerState.processingState == ProcessingState.buffering,
      isCompleted: playerState.processingState == ProcessingState.completed,
    ),
  );

  Duration get currentPosition => _player.position;
  Duration? get currentDuration => _player.duration;
  bool get isPlaying => _player.playing;

  Future<void> setUrl(String url) async {
    try {
      await _player.setUrl(url);
    } catch (e) {
      debugPrint('Error setting audio URL: $e');
      rethrow;
    }
  }

  Future<void> play() async {
    try {
      await _player.play();
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      debugPrint('Error pausing audio: $e');
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      debugPrint('Error seeking: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('Error stopping audio: $e');
    }
  }

  void dispose() {
    _player.dispose();
  }
}

class PlaybackState {
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isBuffering;
  final bool isCompleted;

  PlaybackState({
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.isBuffering,
    required this.isCompleted,
  });

  double get progress {
    if (duration.inMilliseconds == 0) return 0.0;
    return position.inMilliseconds / duration.inMilliseconds;
  }
}
