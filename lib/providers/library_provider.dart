import 'package:flutter/material.dart';
import 'package:rhapsody/models/user_playlist.dart';
import 'package:rhapsody/services/storage/liked_songs_storage.dart';
import 'package:rhapsody/services/storage/user_playlists_storage.dart';

class LibraryProvider with ChangeNotifier {
  final LikedSongsStorage _likedSongsStorage = LikedSongsStorage();
  final UserPlaylistsStorage _playlistsStorage = UserPlaylistsStorage();
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  Set<int> get likedSongIds => _likedSongsStorage.getLikedSongIds();
  List<UserPlaylist> get playlists => _playlistsStorage.getPlaylists();
  int get likedSongsCount => _likedSongsStorage.count;

  Future<void> loadData() async {
    if (_isLoaded) return;
    
    await Future.wait([
      _likedSongsStorage.load(),
      _playlistsStorage.load(),
    ]);
    
    _isLoaded = true;
    notifyListeners();
  }

  bool isLiked(int trackId) => _likedSongsStorage.isLiked(trackId);

  Future<void> toggleLike(int trackId) async {
    await _likedSongsStorage.toggleLike(trackId);
    notifyListeners();
  }

  UserPlaylist? getPlaylist(String id) => _playlistsStorage.getPlaylist(id);

  Future<UserPlaylist> createPlaylist(String name) async {
    final playlist = await _playlistsStorage.createPlaylist(name);
    notifyListeners();
    return playlist;
  }

  Future<void> deletePlaylist(String id) async {
    await _playlistsStorage.deletePlaylist(id);
    notifyListeners();
  }

  Future<void> renamePlaylist(String id, String newName) async {
    await _playlistsStorage.renamePlaylist(id, newName);
    notifyListeners();
  }

  Future<void> addTrackToPlaylist(String playlistId, int trackId) async {
    await _playlistsStorage.addTrackToPlaylist(playlistId, trackId);
    notifyListeners();
  }

  Future<void> removeTrackFromPlaylist(String playlistId, int trackId) async {
    await _playlistsStorage.removeTrackFromPlaylist(playlistId, trackId);
    notifyListeners();
  }
}
