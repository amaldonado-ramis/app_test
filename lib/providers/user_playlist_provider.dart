import 'package:echostream/models/user_playlist.dart';
import 'package:echostream/services/user_playlist_service.dart';
import 'package:flutter/foundation.dart';

class UserPlaylistProvider with ChangeNotifier {
  final UserPlaylistService _service = UserPlaylistService();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    await _service.init();
    _isInitialized = true;
    notifyListeners();
  }

  Future<UserPlaylist> createPlaylist(String name) async {
    final playlist = await _service.createPlaylist(name);
    notifyListeners();
    return playlist;
  }

  Future<void> deletePlaylist(String playlistId) async {
    await _service.deletePlaylist(playlistId);
    notifyListeners();
  }

  Future<void> renamePlaylist(String playlistId, String newName) async {
    await _service.renamePlaylist(playlistId, newName);
    notifyListeners();
  }

  Future<void> addTrackToPlaylist(String playlistId, int trackId) async {
    await _service.addTrackToPlaylist(playlistId, trackId);
    notifyListeners();
  }

  Future<void> removeTrackFromPlaylist(String playlistId, int trackId) async {
    await _service.removeTrackFromPlaylist(playlistId, trackId);
    notifyListeners();
  }

  Future<void> reorderTracks(String playlistId, int oldIndex, int newIndex) async {
    await _service.reorderTracks(playlistId, oldIndex, newIndex);
    notifyListeners();
  }

  UserPlaylist? getPlaylist(String playlistId) => _service.getPlaylist(playlistId);

  List<UserPlaylist> get playlists => _service.playlists;

  int get count => _service.count;
}
