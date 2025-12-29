import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:rhapsody/models/user_playlist.dart';
import 'package:uuid/uuid.dart';

class UserPlaylistsStorage {
  static const String _key = 'user_playlists';
  List<UserPlaylist> _playlists = [];
  bool _isLoaded = false;
  final _uuid = const Uuid();

  Future<void> load() async {
    if (_isLoaded) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_key);
      if (jsonString != null) {
        final List<dynamic> decoded = json.decode(jsonString);
        _playlists = decoded.map((e) => UserPlaylist.fromJson(e)).toList();
      }
      _isLoaded = true;
    } catch (e) {
      debugPrint('Error loading user playlists: $e');
      _playlists = [];
      _isLoaded = true;
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(_playlists.map((p) => p.toJson()).toList());
      await prefs.setString(_key, jsonString);
    } catch (e) {
      debugPrint('Error saving user playlists: $e');
    }
  }

  List<UserPlaylist> getPlaylists() => List.from(_playlists);

  UserPlaylist? getPlaylist(String id) {
    try {
      return _playlists.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<UserPlaylist> createPlaylist(String name) async {
    final playlist = UserPlaylist(
      id: _uuid.v4(),
      name: name,
      createdAt: DateTime.now(),
      trackIds: [],
    );
    _playlists.add(playlist);
    await _save();
    return playlist;
  }

  Future<void> deletePlaylist(String id) async {
    _playlists.removeWhere((p) => p.id == id);
    await _save();
  }

  Future<void> renamePlaylist(String id, String newName) async {
    final index = _playlists.indexWhere((p) => p.id == id);
    if (index != -1) {
      _playlists[index] = _playlists[index].copyWith(name: newName);
      await _save();
    }
  }

  Future<void> addTrackToPlaylist(String playlistId, int trackId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final trackIds = List<int>.from(_playlists[index].trackIds);
      if (!trackIds.contains(trackId)) {
        trackIds.add(trackId);
        _playlists[index] = _playlists[index].copyWith(trackIds: trackIds);
        await _save();
      }
    }
  }

  Future<void> removeTrackFromPlaylist(String playlistId, int trackId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final trackIds = List<int>.from(_playlists[index].trackIds);
      trackIds.remove(trackId);
      _playlists[index] = _playlists[index].copyWith(trackIds: trackIds);
      await _save();
    }
  }

  int get count => _playlists.length;
}
