import 'package:flutter/material.dart';
import 'package:rhapsody/models/track.dart';
import 'package:rhapsody/services/api/tidal_api_client.dart';
import 'package:rhapsody/services/playback/audio_player_service.dart';
import 'package:rhapsody/services/playback/queue_manager.dart';
import 'package:rhapsody/services/playback/playback_controller.dart';

class PlaybackProvider with ChangeNotifier {
  late final PlaybackController _controller;
  late final AudioPlayerService _audioPlayer;
  late final QueueManager _queueManager;
  PlaybackState? _playbackState;

  PlaybackProvider() {
    _audioPlayer = AudioPlayerService();
    _queueManager = QueueManager();
    _controller = PlaybackController(_audioPlayer, _queueManager, TidalApiClient());
    
    _audioPlayer.playbackStateStream.listen((state) {
      _playbackState = state;
      notifyListeners();
      
      if (state.isCompleted && !_controller.isLoadingTrack) {
        _handleTrackCompleted();
      }
    });
  }

  PlaybackController get controller => _controller;
  QueueManager get queueManager => _queueManager;
  Track? get currentTrack => _queueManager.currentTrack;
  List<Track> get queue => _queueManager.queue;
  int get currentIndex => _queueManager.currentIndex;
  bool get shuffleEnabled => _queueManager.shuffleEnabled;
  RepeatMode get repeatMode => _queueManager.repeatMode;
  PlaybackState? get playbackState => _playbackState;
  bool get isPlaying => _playbackState?.isPlaying ?? false;
  bool get isBuffering => _playbackState?.isBuffering ?? false;
  bool get isLoadingTrack => _controller.isLoadingTrack;

  Future<void> playTrack(Track track) async {
    await _controller.playTrack(track);
    notifyListeners();
  }

  Future<void> playQueue(List<Track> tracks, {int startIndex = 0}) async {
    await _controller.playQueue(tracks, startIndex: startIndex);
    notifyListeners();
  }

  Future<void> play() async {
    await _controller.play();
    notifyListeners();
  }

  Future<void> pause() async {
    await _controller.pause();
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    await _controller.togglePlayPause();
    notifyListeners();
  }

  Future<void> next() async {
    await _controller.next();
    notifyListeners();
  }

  Future<void> previous() async {
    await _controller.previous();
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _controller.seek(position);
  }

  Future<void> addToQueue(Track track) async {
    await _controller.addToQueue(track);
    notifyListeners();
  }

  Future<void> addNextInQueue(Track track) async {
    await _controller.addNextInQueue(track);
    notifyListeners();
  }

  void toggleShuffle() {
    _controller.toggleShuffle();
    notifyListeners();
  }

  void cycleRepeatMode() {
    _controller.cycleRepeatMode();
    notifyListeners();
  }

  void removeFromQueue(int index) {
    _queueManager.removeFromQueue(index);
    notifyListeners();
  }

  void jumpToIndex(int index) {
    _queueManager.jumpToIndex(index);
    final track = _queueManager.currentTrack;
    if (track != null) {
      playTrack(track);
    }
  }

  Future<void> _handleTrackCompleted() async {
    if (_queueManager.hasNext) {
      await next();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
