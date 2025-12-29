import 'dart:convert';
import 'package:echostream/models/user_playlist.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class UserPlaylistService {
  static const String _key = 'user_playlists';
  List<UserPlaylist> _playlists = [];
  bool _isLoaded = false;
  final _uuid = const Uuid();

  Future<void> init() async {
    if (_isLoaded) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_key);
      if (data != null) {
        final List<dynamic> decoded = json.decode(data);
        _playlists = decoded
            .map((item) {
              try {
                return UserPlaylist.fromJson(item as Map<String, dynamic>);
              } catch (e) {
                debugPrint('Error parsing playlist: $e');
                return null;
              }
            })
            .whereType<UserPlaylist>()
            .toList();
      }
      _isLoaded = true;
    } catch (e) {
      debugPrint('Error loading playlists: $e');
      _playlists = [];
      _isLoaded = true;
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, json.encode(_playlists.map((p) => p.toJson()).toList()));
    } catch (e) {
      debugPrint('Error saving playlists: $e');
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

  Future<void> deletePlaylist(String playlistId) async {
    _playlists.removeWhere((p) => p.id == playlistId);
    await _save();
  }

  Future<void> renamePlaylist(String playlistId, String newName) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
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

  Future<void> reorderTracks(String playlistId, int oldIndex, int newIndex) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final trackIds = List<int>.from(_playlists[index].trackIds);
      final item = trackIds.removeAt(oldIndex);
      trackIds.insert(newIndex, item);
      _playlists[index] = _playlists[index].copyWith(trackIds: trackIds);
      await _save();
    }
  }

  UserPlaylist? getPlaylist(String playlistId) {
    try {
      return _playlists.firstWhere((p) => p.id == playlistId);
    } catch (e) {
      return null;
    }
  }

  List<UserPlaylist> get playlists => List.unmodifiable(_playlists);

  int get count => _playlists.length;
}
