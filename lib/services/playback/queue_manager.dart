import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:rhapsody/models/track.dart';

enum RepeatMode { off, all, one }

class QueueManager {
  List<Track> _originalQueue = [];
  List<Track> _queue = [];
  int _currentIndex = -1;
  bool _shuffleEnabled = false;
  RepeatMode _repeatMode = RepeatMode.off;
  List<int> _shuffleIndices = [];

  List<Track> get queue => List.from(_queue);
  int get currentIndex => _currentIndex;
  Track? get currentTrack => _currentIndex >= 0 && _currentIndex < _queue.length 
      ? _queue[_currentIndex] 
      : null;
  bool get shuffleEnabled => _shuffleEnabled;
  RepeatMode get repeatMode => _repeatMode;
  bool get hasNext => _getNextIndex() != null;
  bool get hasPrevious => _getPreviousIndex() != null;

  void setQueue(List<Track> tracks, {int startIndex = 0}) {
    _originalQueue = List.from(tracks);
    _queue = List.from(tracks);
    _currentIndex = startIndex.clamp(0, tracks.length - 1);
    
    if (_shuffleEnabled) {
      _generateShuffleIndices();
      _applyShuffleFromCurrent();
    }
  }

  void addToQueue(Track track) {
    _queue.add(track);
    _originalQueue.add(track);
    if (_shuffleEnabled) {
      _generateShuffleIndices();
    }
  }

  void addNextInQueue(Track track) {
    final insertIndex = _currentIndex + 1;
    _queue.insert(insertIndex, track);
    _originalQueue.insert(insertIndex, track);
    if (_shuffleEnabled) {
      _generateShuffleIndices();
    }
  }

  void removeFromQueue(int index) {
    if (index < 0 || index >= _queue.length) return;
    
    final track = _queue[index];
    _queue.removeAt(index);
    _originalQueue.remove(track);
    
    if (index < _currentIndex) {
      _currentIndex--;
    } else if (index == _currentIndex) {
      if (_currentIndex >= _queue.length) {
        _currentIndex = _queue.length - 1;
      }
    }
    
    if (_shuffleEnabled) {
      _generateShuffleIndices();
    }
  }

  void moveTrack(int from, int to) {
    if (from < 0 || from >= _queue.length || to < 0 || to >= _queue.length) return;
    
    final track = _queue.removeAt(from);
    _queue.insert(to, track);
    
    if (_currentIndex == from) {
      _currentIndex = to;
    } else if (from < _currentIndex && to >= _currentIndex) {
      _currentIndex--;
    } else if (from > _currentIndex && to <= _currentIndex) {
      _currentIndex++;
    }
  }

  void clearQueue() {
    _queue.clear();
    _originalQueue.clear();
    _currentIndex = -1;
    _shuffleIndices.clear();
  }

  Track? next() {
    final nextIndex = _getNextIndex();
    if (nextIndex != null) {
      _currentIndex = nextIndex;
      return currentTrack;
    }
    return null;
  }

  Track? previous() {
    final prevIndex = _getPreviousIndex();
    if (prevIndex != null) {
      _currentIndex = prevIndex;
      return currentTrack;
    }
    return null;
  }

  void jumpToIndex(int index) {
    if (index >= 0 && index < _queue.length) {
      _currentIndex = index;
    }
  }

  void toggleShuffle() {
    _shuffleEnabled = !_shuffleEnabled;
    
    if (_shuffleEnabled) {
      _generateShuffleIndices();
      _applyShuffleFromCurrent();
    } else {
      _queue = List.from(_originalQueue);
      final currentTrack = this.currentTrack;
      if (currentTrack != null) {
        _currentIndex = _originalQueue.indexWhere((t) => t.id == currentTrack.id);
      }
    }
  }

  void setRepeatMode(RepeatMode mode) {
    _repeatMode = mode;
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

  int? _getNextIndex() {
    if (_queue.isEmpty) return null;
    
    if (_repeatMode == RepeatMode.one) {
      return _currentIndex;
    }
    
    if (_currentIndex < _queue.length - 1) {
      return _currentIndex + 1;
    }
    
    if (_repeatMode == RepeatMode.all) {
      return 0;
    }
    
    return null;
  }

  int? _getPreviousIndex() {
    if (_queue.isEmpty) return null;
    
    if (_repeatMode == RepeatMode.one) {
      return _currentIndex;
    }
    
    if (_currentIndex > 0) {
      return _currentIndex - 1;
    }
    
    if (_repeatMode == RepeatMode.all) {
      return _queue.length - 1;
    }
    
    return null;
  }

  void _generateShuffleIndices() {
    _shuffleIndices = List.generate(_originalQueue.length, (index) => index);
    _shuffleIndices.shuffle(Random());
  }

  void _applyShuffleFromCurrent() {
    if (_currentIndex < 0 || _currentIndex >= _queue.length) return;
    
    final currentTrack = _queue[_currentIndex];
    final shuffledQueue = <Track>[];
    
    shuffledQueue.add(currentTrack);
    
    for (var idx in _shuffleIndices) {
      final track = _originalQueue[idx];
      if (track.id != currentTrack.id) {
        shuffledQueue.add(track);
      }
    }
    
    _queue = shuffledQueue;
    _currentIndex = 0;
  }
}
