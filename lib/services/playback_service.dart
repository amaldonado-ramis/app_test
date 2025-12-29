import 'package:audio_session/audio_session.dart';
import 'package:echostream/models/track.dart';
import 'package:echostream/services/track_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

enum RepeatMode { off, all, one }

class PlaybackService {
  final AudioPlayer _player = AudioPlayer();
  final TrackService _trackService = TrackService();
  
  List<Track> _queue = [];
  int _currentIndex = -1;
  bool _isShuffled = false;
  RepeatMode _repeatMode = RepeatMode.off;
  List<int> _shuffleIndices = [];

  AudioPlayer get player => _player;
  List<Track> get queue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;
  Track? get currentTrack => _currentIndex >= 0 && _currentIndex < _queue.length ? _queue[_currentIndex] : null;
  bool get isShuffled => _isShuffled;
  RepeatMode get repeatMode => _repeatMode;
  bool get hasNext => _getNextIndex() != -1;
  bool get hasPrevious => _getPreviousIndex() != -1;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<bool> get playingStream => _player.playingStream;

  Future<void> init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _onTrackCompleted();
      }
    });
  }

  Future<void> setQueue(List<Track> tracks, {int startIndex = 0}) async {
    _queue = tracks;
    _currentIndex = startIndex;
    _shuffleIndices = List.generate(tracks.length, (i) => i);
    if (_isShuffled) {
      _shuffleQueue(preserveCurrent: true);
    }
    await playTrackAt(startIndex);
  }

  Future<void> addToQueue(Track track) async {
    _queue.add(track);
    if (_isShuffled) {
      _shuffleIndices.add(_shuffleIndices.length);
    }
  }

  Future<void> playTrackAt(int index) async {
    if (index < 0 || index >= _queue.length) return;
    
    _currentIndex = index;
    final track = _queue[index];
    
    try {
      // First check if we already have a stream URL or need to fetch it
      // Note: Since the API requires fetching the stream URL separately, 
      // we do it here.
      final streamInfo = await _trackService.getStreamInfo(track.id);
      if (streamInfo == null) {
        debugPrint('Could not get stream URL for track ${track.id}');
        await next();
        return;
      }

      final mediaItem = MediaItem(
        id: track.id.toString(),
        album: track.albumTitle,
        title: track.title,
        artist: track.artistName,
        artUri: track.albumCoverUrl.isNotEmpty ? Uri.parse(track.albumCoverUrl) : null,
        duration: Duration(seconds: track.duration),
      );

      final audioSource = AudioSource.uri(
        Uri.parse(streamInfo.url),
        tag: mediaItem,
      );

      await _player.setAudioSource(audioSource);
      await _player.play();
    } catch (e) {
      debugPrint('Error playing track: $e');
      await next();
    }
  }

  Future<void> play() async {
    if (_player.playerState.processingState == ProcessingState.idle && currentTrack != null) {
      await playTrackAt(_currentIndex);
    } else {
      await _player.play();
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> next() async {
    final nextIndex = _getNextIndex();
    if (nextIndex != -1) {
      await playTrackAt(nextIndex);
    }
  }

  Future<void> previous() async {
    if (_player.position.inSeconds > 3) {
      await seek(Duration.zero);
    } else {
      final prevIndex = _getPreviousIndex();
      if (prevIndex != -1) {
        await playTrackAt(prevIndex);
      }
    }
  }

  int _getNextIndex() {
    if (_queue.isEmpty) return -1;

    if (_repeatMode == RepeatMode.one) {
      return _currentIndex;
    }

    int nextIndex;
    if (_isShuffled) {
      final currentShufflePos = _shuffleIndices.indexOf(_currentIndex);
      if (currentShufflePos < _shuffleIndices.length - 1) {
        nextIndex = _shuffleIndices[currentShufflePos + 1];
      } else if (_repeatMode == RepeatMode.all) {
        nextIndex = _shuffleIndices[0];
      } else {
        return -1;
      }
    } else {
      if (_currentIndex < _queue.length - 1) {
        nextIndex = _currentIndex + 1;
      } else if (_repeatMode == RepeatMode.all) {
        nextIndex = 0;
      } else {
        return -1;
      }
    }

    return nextIndex;
  }

  int _getPreviousIndex() {
    if (_queue.isEmpty) return -1;

    int prevIndex;
    if (_isShuffled) {
      final currentShufflePos = _shuffleIndices.indexOf(_currentIndex);
      if (currentShufflePos > 0) {
        prevIndex = _shuffleIndices[currentShufflePos - 1];
      } else if (_repeatMode == RepeatMode.all) {
        prevIndex = _shuffleIndices[_shuffleIndices.length - 1];
      } else {
        return -1;
      }
    } else {
      if (_currentIndex > 0) {
        prevIndex = _currentIndex - 1;
      } else if (_repeatMode == RepeatMode.all) {
        prevIndex = _queue.length - 1;
      } else {
        return -1;
      }
    }

    return prevIndex;
  }

  Future<void> _onTrackCompleted() async {
    if (_repeatMode == RepeatMode.one) {
       await seek(Duration.zero);
       await play();
    } else {
       await next();
    }
  }

  void toggleShuffle() {
    _isShuffled = !_isShuffled;
    if (_isShuffled) {
      _shuffleQueue(preserveCurrent: true);
    } else {
      _shuffleIndices = List.generate(_queue.length, (i) => i);
    }
  }

  void _shuffleQueue({bool preserveCurrent = false}) {
    if (_queue.isEmpty) return;
    
    _shuffleIndices = List.generate(_queue.length, (i) => i);
    
    if (preserveCurrent && _currentIndex >= 0) {
      _shuffleIndices.remove(_currentIndex);
      _shuffleIndices.shuffle();
      _shuffleIndices.insert(0, _currentIndex);
    } else {
      _shuffleIndices.shuffle();
    }
  }

  void cycleRepeatMode() {
    switch (_repeatMode) {
      case RepeatMode.off:
        _repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.off;
        break;
    }
  }

  void clearQueue() {
    _queue.clear();
    _currentIndex = -1;
    _shuffleIndices.clear();
    _player.stop();
  }

  void dispose() {
    _player.dispose();
  }
}
