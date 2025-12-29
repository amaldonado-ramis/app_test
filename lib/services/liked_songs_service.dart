import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LikedSongsService {
  static const String _key = 'liked_songs';
  Set<int> _likedSongs = {};
  bool _isLoaded = false;

  Future<void> init() async {
    if (_isLoaded) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_key);
      if (data != null) {
        final List<dynamic> decoded = json.decode(data);
        _likedSongs = decoded.cast<int>().toSet();
      }
      _isLoaded = true;
    } catch (e) {
      debugPrint('Error loading liked songs: $e');
      _likedSongs = {};
      _isLoaded = true;
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, json.encode(_likedSongs.toList()));
    } catch (e) {
      debugPrint('Error saving liked songs: $e');
    }
  }

  bool isLiked(int trackId) => _likedSongs.contains(trackId);

  Future<void> toggleLike(int trackId) async {
    if (_likedSongs.contains(trackId)) {
      _likedSongs.remove(trackId);
    } else {
      _likedSongs.add(trackId);
    }
    await _save();
  }

  Set<int> get likedSongs => Set.unmodifiable(_likedSongs);

  int get count => _likedSongs.length;
}
