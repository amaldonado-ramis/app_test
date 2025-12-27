import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:echobeat/models/track.dart';
import 'package:echobeat/services/api_service.dart';
import 'package:echobeat/services/playback_service.dart';

class PlaybackProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final PlaybackService _playbackService = PlaybackService();

  Track? _currentTrack;
  Track? get currentTrack => _currentTrack;

  List<Track> _queue = [];
  List<Track> get queue => _queue;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  PlayerState _playerState = PlayerState.stopped;
  PlayerState get playerState => _playerState;

  Duration _position = Duration.zero;
  Duration get position => _position;

  Duration _duration = Duration.zero;
  Duration get duration => _duration;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  StreamSubscription? _stateSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;

  PlaybackProvider() {
    _initializeListeners();
  }

  void _initializeListeners() {
    _stateSubscription = _playbackService.onStateChanged.listen((state) {
      _playerState = state;
      if (state == PlayerState.stopped && _currentIndex < _queue.length - 1) {
        playNext();
      }
      notifyListeners();
    });

    _positionSubscription = _playbackService.onPositionChanged.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _durationSubscription = _playbackService.onDurationChanged.listen((dur) {
      _duration = dur ?? Duration.zero;
      notifyListeners();
    });
  }

  Future<void> playTrack(Track track, {List<Track>? playlist}) async {
    if (!track.streamable) {
      _error = 'This track is not streamable';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (playlist != null) {
        _queue = playlist;
        _currentIndex = playlist.indexOf(track);
      } else {
        _queue = [track];
        _currentIndex = 0;
      }

      _currentTrack = track;
      final streamUrl = await _apiService.getStreamUrl(track.id);
      
      if (streamUrl.isEmpty) {
        throw Exception('Failed to get stream URL');
      }

      await _playbackService.play(streamUrl);
    } catch (e) {
      debugPrint('Error playing track: $e');
      _error = 'Failed to play track';
      _playerState = PlayerState.error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> togglePlayPause() async {
    if (_playerState == PlayerState.playing) {
      await _playbackService.pause();
    } else if (_playerState == PlayerState.paused) {
      await _playbackService.resume();
    }
  }

  Future<void> playNext() async {
    if (_currentIndex < _queue.length - 1) {
      _currentIndex++;
      await playTrack(_queue[_currentIndex], playlist: _queue);
    }
  }

  Future<void> playPrevious() async {
    if (_position.inSeconds > 3) {
      await seek(Duration.zero);
    } else if (_currentIndex > 0) {
      _currentIndex--;
      await playTrack(_queue[_currentIndex], playlist: _queue);
    }
  }

  Future<void> seek(Duration position) async {
    await _playbackService.seek(position);
  }

  Future<void> stop() async {
    await _playbackService.stop();
    _currentTrack = null;
    _queue = [];
    _currentIndex = 0;
    _position = Duration.zero;
    _duration = Duration.zero;
    notifyListeners();
  }

  bool get hasNext => _currentIndex < _queue.length - 1;
  bool get hasPrevious => _currentIndex > 0 || _position.inSeconds > 3;
  bool get isPlaying => _playerState == PlayerState.playing;

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playbackService.dispose();
    _apiService.dispose();
    super.dispose();
  }
}
