import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class LikedSongsStorage {
  static const String _key = 'liked_song_ids';
  Set<int> _likedSongIds = {};
  bool _isLoaded = false;

  Future<void> load() async {
    if (_isLoaded) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_key);
      if (jsonString != null) {
        final List<dynamic> decoded = json.decode(jsonString);
        _likedSongIds = decoded.map((e) => e as int).toSet();
      }
      _isLoaded = true;
    } catch (e) {
      debugPrint('Error loading liked songs: $e');
      _likedSongIds = {};
      _isLoaded = true;
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(_likedSongIds.toList());
      await prefs.setString(_key, jsonString);
    } catch (e) {
      debugPrint('Error saving liked songs: $e');
    }
  }

  bool isLiked(int trackId) {
    return _likedSongIds.contains(trackId);
  }

  Future<void> toggleLike(int trackId) async {
    if (_likedSongIds.contains(trackId)) {
      _likedSongIds.remove(trackId);
    } else {
      _likedSongIds.add(trackId);
    }
    await _save();
  }

  Set<int> getLikedSongIds() => Set.from(_likedSongIds);

  int get count => _likedSongIds.length;
}
