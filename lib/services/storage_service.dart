import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:echobeat/models/track.dart';
import 'package:echobeat/models/playlist.dart';

class StorageService {
  static const String _likedSongsKey = 'liked_songs';
  static const String _playlistsKey = 'playlists';
  static const String _trackCacheKey = 'track_cache';

  Future<Set<int>> getLikedSongs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final likedJson = prefs.getString(_likedSongsKey);
      if (likedJson != null) {
        final List<dynamic> list = json.decode(likedJson);
        return list.map((e) => e as int).toSet();
      }
      return {};
    } catch (e) {
      debugPrint('Error loading liked songs: $e');
      return {};
    } finally {
      // Ensure we don't get stuck in loading state
    }
  }

  Future<void> saveLikedSongs(Set<int> likedSongs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_likedSongsKey, json.encode(likedSongs.toList()));
    } catch (e) {
      debugPrint('Error saving liked songs: $e');
    }
  }

  Future<List<Playlist>> getPlaylists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playlistsJson = prefs.getString(_playlistsKey);
      if (playlistsJson != null) {
        final List<dynamic> list = json.decode(playlistsJson);
        return list.map((e) => Playlist.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error loading playlists: $e');
      return [];
    } finally {
      // Ensure we don't get stuck in loading state
    }
  }

  Future<void> savePlaylists(List<Playlist> playlists) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playlistsJson = playlists.map((p) => p.toJson()).toList();
      await prefs.setString(_playlistsKey, json.encode(playlistsJson));
    } catch (e) {
      debugPrint('Error saving playlists: $e');
    }
  }

  Future<Map<int, Track>> getTrackCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheJson = prefs.getString(_trackCacheKey);
      if (cacheJson != null) {
        final Map<String, dynamic> map = json.decode(cacheJson);
        return map.map((key, value) => MapEntry(
          int.parse(key),
          Track.fromJson(value as Map<String, dynamic>),
        ));
      }
      return {};
    } catch (e) {
      debugPrint('Error loading track cache: $e');
      return {};
    }
  }

  Future<void> saveTrackCache(Map<int, Track> cache) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheJson = cache.map((key, value) => MapEntry(key.toString(), value.toJson()));
      await prefs.setString(_trackCacheKey, json.encode(cacheJson));
    } catch (e) {
      debugPrint('Error saving track cache: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      debugPrint('Error clearing storage: $e');
    }
  }
}
