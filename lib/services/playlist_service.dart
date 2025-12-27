import 'package:uuid/uuid.dart';
import 'package:echobeat/models/playlist.dart';
import 'package:echobeat/services/storage_service.dart';

class PlaylistService {
  final StorageService _storage = StorageService();
  final Uuid _uuid = const Uuid();

  Future<List<Playlist>> getAllPlaylists() async => await _storage.getPlaylists();

  Future<Playlist> createPlaylist(String name) async {
    final playlists = await _storage.getPlaylists();
    final newPlaylist = Playlist(
      id: _uuid.v4(),
      name: name,
      createdAt: DateTime.now(),
      trackIds: [],
    );
    playlists.add(newPlaylist);
    await _storage.savePlaylists(playlists);
    return newPlaylist;
  }

  Future<void> deletePlaylist(String playlistId) async {
    final playlists = await _storage.getPlaylists();
    playlists.removeWhere((p) => p.id == playlistId);
    await _storage.savePlaylists(playlists);
  }

  Future<void> renamePlaylist(String playlistId, String newName) async {
    final playlists = await _storage.getPlaylists();
    final index = playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      playlists[index] = playlists[index].copyWith(name: newName);
      await _storage.savePlaylists(playlists);
    }
  }

  Future<void> addTrackToPlaylist(String playlistId, int trackId) async {
    final playlists = await _storage.getPlaylists();
    final index = playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final trackIds = List<int>.from(playlists[index].trackIds);
      if (!trackIds.contains(trackId)) {
        trackIds.add(trackId);
        playlists[index] = playlists[index].copyWith(trackIds: trackIds);
        await _storage.savePlaylists(playlists);
      }
    }
  }

  Future<void> removeTrackFromPlaylist(String playlistId, int trackId) async {
    final playlists = await _storage.getPlaylists();
    final index = playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final trackIds = List<int>.from(playlists[index].trackIds);
      trackIds.remove(trackId);
      playlists[index] = playlists[index].copyWith(trackIds: trackIds);
      await _storage.savePlaylists(playlists);
    }
  }
}
