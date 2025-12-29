import 'package:flutter/foundation.dart';
import 'package:rhapsody/models/track.dart';
import 'package:rhapsody/models/stream_info.dart';
import 'package:rhapsody/services/api/tidal_api_client.dart';
import 'package:rhapsody/services/api/track_api.dart';
import 'package:rhapsody/services/playback/audio_player_service.dart';
import 'package:rhapsody/services/playback/queue_manager.dart';

class PlaybackController {
  final AudioPlayerService _audioPlayer;
  final QueueManager _queueManager;
  final TrackApi _trackApi;
  
  StreamInfo? _currentStreamInfo;
  bool _isLoadingTrack = false;

  PlaybackController(this._audioPlayer, this._queueManager, TidalApiClient apiClient)
      : _trackApi = TrackApi(apiClient);

  AudioPlayerService get audioPlayer => _audioPlayer;
  QueueManager get queueManager => _queueManager;
  Track? get currentTrack => _queueManager.currentTrack;
  bool get isLoadingTrack => _isLoadingTrack;

  Future<bool> playTrack(Track track) async {
    try {
      _isLoadingTrack = true;
      
      if (_currentStreamInfo != null && _currentStreamInfo!.isExpired) {
        _currentStreamInfo = null;
      }

      _currentStreamInfo = await _trackApi.getStreamInfo(track.id);
      
      if (_currentStreamInfo == null) {
        debugPrint('Failed to get stream info for track ${track.id}');
        _isLoadingTrack = false;
        return false;
      }

      await _audioPlayer.setUrl(_currentStreamInfo!.url);
      await _audioPlayer.play();
      
      _isLoadingTrack = false;
      return true;
    } catch (e) {
      debugPrint('Error playing track: $e');
      _isLoadingTrack = false;
      return false;
    }
  }

  Future<void> playQueue(List<Track> tracks, {int startIndex = 0}) async {
    _queueManager.setQueue(tracks, startIndex: startIndex);
    final track = _queueManager.currentTrack;
    if (track != null) {
      await playTrack(track);
    }
  }

  Future<void> play() async {
    if (_queueManager.currentTrack == null) return;
    
    if (_currentStreamInfo == null || _currentStreamInfo!.isExpired) {
      await playTrack(_queueManager.currentTrack!);
    } else {
      await _audioPlayer.play();
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> togglePlayPause() async {
    if (_audioPlayer.isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> next() async {
    final nextTrack = _queueManager.next();
    if (nextTrack != null) {
      await playTrack(nextTrack);
    }
  }

  Future<void> previous() async {
    if (_audioPlayer.currentPosition.inSeconds > 3) {
      await _audioPlayer.seek(Duration.zero);
    } else {
      final prevTrack = _queueManager.previous();
      if (prevTrack != null) {
        await playTrack(prevTrack);
      }
    }
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> addToQueue(Track track) async {
    _queueManager.addToQueue(track);
  }

  Future<void> addNextInQueue(Track track) async {
    _queueManager.addNextInQueue(track);
  }

  void toggleShuffle() {
    _queueManager.toggleShuffle();
  }

  void cycleRepeatMode() {
    _queueManager.cycleRepeatMode();
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
