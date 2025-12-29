import 'package:echostream/models/track.dart';
import 'package:echostream/services/playback_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class PlaybackProvider with ChangeNotifier {
  final PlaybackService _service = PlaybackService();
  bool _isInitialized = false;

  PlaybackService get service => _service;
  List<Track> get queue => _service.queue;
  Track? get currentTrack => _service.currentTrack;
  int get currentIndex => _service.currentIndex;
  bool get isShuffled => _service.isShuffled;
  RepeatMode get repeatMode => _service.repeatMode;
  bool get hasNext => _service.hasNext;
  bool get hasPrevious => _service.hasPrevious;

  Stream<Duration> get positionStream => _service.positionStream;
  Stream<Duration?> get durationStream => _service.durationStream;
  Stream<PlayerState> get playerStateStream => _service.playerStateStream;
  Stream<bool> get playingStream => _service.playingStream;

  Future<void> init() async {
    if (_isInitialized) return;
    await _service.init();
    _isInitialized = true;
    
    _service.playerStateStream.listen((_) {
      notifyListeners();
    });
  }

  Future<void> setQueue(List<Track> tracks, {int startIndex = 0}) async {
    await _service.setQueue(tracks, startIndex: startIndex);
    notifyListeners();
  }

  Future<void> addToQueue(Track track) async {
    await _service.addToQueue(track);
    notifyListeners();
  }

  Future<void> playTrackAt(int index) async {
    await _service.playTrackAt(index);
    notifyListeners();
  }

  Future<void> play() async {
    await _service.play();
  }

  Future<void> pause() async {
    await _service.pause();
  }

  Future<void> togglePlayPause() async {
    await _service.togglePlayPause();
  }

  Future<void> seek(Duration position) async {
    await _service.seek(position);
  }

  Future<void> next() async {
    await _service.next();
  }

  Future<void> previous() async {
    await _service.previous();
  }

  void toggleShuffle() {
    _service.toggleShuffle();
    notifyListeners();
  }

  void cycleRepeatMode() {
    _service.cycleRepeatMode();
    notifyListeners();
  }

  void clearQueue() {
    _service.clearQueue();
    notifyListeners();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
