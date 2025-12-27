import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter/foundation.dart';

enum PlayerState { stopped, playing, paused, buffering, error }

class PlaybackService {
  final ap.AudioPlayer _player = ap.AudioPlayer();
  
  PlayerState _state = PlayerState.stopped;
  PlayerState get state => _state;
  
  Duration _duration = Duration.zero;
  Duration get duration => _duration;
  
  Duration _position = Duration.zero;
  Duration get position => _position;

  Stream<PlayerState> get onStateChanged => _player.onPlayerStateChanged.map((state) {
    switch (state) {
      case ap.PlayerState.playing:
        _state = PlayerState.playing;
        return PlayerState.playing;
      case ap.PlayerState.paused:
        _state = PlayerState.paused;
        return PlayerState.paused;
      case ap.PlayerState.stopped:
        _state = PlayerState.stopped;
        return PlayerState.stopped;
      case ap.PlayerState.completed:
        _state = PlayerState.stopped;
        return PlayerState.stopped;
      default:
        return _state;
    }
  });

  Stream<Duration> get onPositionChanged => _player.onPositionChanged.map((pos) {
    _position = pos;
    return pos;
  });

  Stream<Duration?> get onDurationChanged => _player.onDurationChanged.map((dur) {
    _duration = dur ?? Duration.zero;
    return dur;
  });

  Future<void> play(String url) async {
    try {
      _state = PlayerState.buffering;
      await _player.play(ap.UrlSource(url));
    } catch (e) {
      debugPrint('Error playing track: $e');
      _state = PlayerState.error;
      rethrow;
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      debugPrint('Error pausing: $e');
    }
  }

  Future<void> resume() async {
    try {
      await _player.resume();
    } catch (e) {
      debugPrint('Error resuming: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
      _position = Duration.zero;
    } catch (e) {
      debugPrint('Error stopping: $e');
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      debugPrint('Error seeking: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      await _player.setVolume(volume);
    } catch (e) {
      debugPrint('Error setting volume: $e');
    }
  }

  void dispose() {
    _player.dispose();
  }
}
