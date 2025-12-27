import 'package:flutter/foundation.dart';
import 'package:echobeat/models/track.dart';
import 'package:echobeat/models/playlist.dart';
import 'package:echobeat/services/storage_service.dart';
import 'package:echobeat/services/playlist_service.dart';

class LibraryProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  final PlaylistService _playlistService = PlaylistService();

  Set<int> _likedSongIds = {};
  Set<int> get likedSongIds => _likedSongIds;

  Map<int, Track> _trackCache = {};
  Map<int, Track> get trackCache => _trackCache;

  List<Playlist> _playlists = [];
  List<Playlist> get playlists => _playlists;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _likedSongIds = await _storageService.getLikedSongs();
      _playlists = await _playlistService.getAllPlaylists();
      _trackCache = await _storageService.getTrackCache();
    } catch (e) {
      debugPrint('Error initializing library: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isLiked(int trackId) => _likedSongIds.contains(trackId);

  Future<void> toggleLike(Track track) async {
    if (_likedSongIds.contains(track.id)) {
      _likedSongIds.remove(track.id);
    } else {
      _likedSongIds.add(track.id);
      _trackCache[track.id] = track;
      await _storageService.saveTrackCache(_trackCache);
    }
    await _storageService.saveLikedSongs(_likedSongIds);
    notifyListeners();
  }

  List<Track> getLikedTracks() {
    return _likedSongIds
        .map((id) => _trackCache[id])
        .whereType<Track>()
        .toList();
  }

  Future<void> createPlaylist(String name) async {
    final playlist = await _playlistService.createPlaylist(name);
    _playlists.add(playlist);
    notifyListeners();
  }

  Future<void> deletePlaylist(String playlistId) async {
    await _playlistService.deletePlaylist(playlistId);
    _playlists.removeWhere((p) => p.id == playlistId);
    notifyListeners();
  }

  Future<void> renamePlaylist(String playlistId, String newName) async {
    await _playlistService.renamePlaylist(playlistId, newName);
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      _playlists[index] = _playlists[index].copyWith(name: newName);
      notifyListeners();
    }
  }

  Future<void> addTrackToPlaylist(String playlistId, Track track) async {
    await _playlistService.addTrackToPlaylist(playlistId, track.id);
    _trackCache[track.id] = track;
    await _storageService.saveTrackCache(_trackCache);
    
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final trackIds = List<int>.from(_playlists[index].trackIds);
      if (!trackIds.contains(track.id)) {
        trackIds.add(track.id);
        _playlists[index] = _playlists[index].copyWith(trackIds: trackIds);
        notifyListeners();
      }
    }
  }

  Future<void> removeTrackFromPlaylist(String playlistId, int trackId) async {
    await _playlistService.removeTrackFromPlaylist(playlistId, trackId);
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final trackIds = List<int>.from(_playlists[index].trackIds);
      trackIds.remove(trackId);
      _playlists[index] = _playlists[index].copyWith(trackIds: trackIds);
      notifyListeners();
    }
  }

  List<Track> getPlaylistTracks(String playlistId) {
    final playlist = _playlists.firstWhere((p) => p.id == playlistId);
    return playlist.trackIds
        .map((id) => _trackCache[id])
        .whereType<Track>()
        .toList();
  }

  void cacheTrack(Track track) {
    _trackCache[track.id] = track;
    _storageService.saveTrackCache(_trackCache);
  }

  void cacheTracks(List<Track> tracks) {
    for (final track in tracks) {
      _trackCache[track.id] = track;
    }
    _storageService.saveTrackCache(_trackCache);
  }
}
