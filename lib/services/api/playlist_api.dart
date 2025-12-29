import 'package:flutter/foundation.dart';
import 'package:rhapsody/models/playlist.dart';
import 'package:rhapsody/models/track.dart';
import 'package:rhapsody/services/api/tidal_api_client.dart';
import 'package:rhapsody/services/api/search_normalizer.dart';

class PlaylistApi {
  final TidalApiClient _client;

  PlaylistApi(this._client);

  Future<List<Playlist>> searchPlaylists(String query) async {
    try {
      final response = await _client.get('/search/', queryParams: {'p': query});
      final items = SearchNormalizer.extractItems(response, entityType: 'playlist');
      return items.map((json) => Playlist.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error searching playlists: $e');
      return [];
    }
  }

  Future<PlaylistDetails?> getPlaylistDetails(String playlistId) async {
    try {
      final response = await _client.get('/playlist/', queryParams: {'id': playlistId});
      
      dynamic playlistData = response;
      if (playlistData is Map && playlistData.containsKey('data')) {
        playlistData = playlistData['data'];
      }

      if (playlistData is! Map<String, dynamic>) {
        debugPrint('Invalid playlist data structure');
        return null;
      }

      Playlist playlist;
      try {
        playlist = Playlist.fromJson(playlistData);
      } catch (e) {
        debugPrint('Error parsing playlist metadata: $e');
        playlist = Playlist(
          id: playlistId,
          title: playlistData['title'] ?? 'Unknown Playlist',
          numberOfTracks: 0,
        );
      }

      final trackItems = SearchNormalizer.extractTracksFromAny(playlistData);
      final tracks = trackItems.map((json) {
        try {
          return Track.fromJson(json);
        } catch (e) {
          debugPrint('Error parsing track: $e');
          return null;
        }
      }).whereType<Track>().toList();

      return PlaylistDetails(playlist: playlist, tracks: tracks);
    } catch (e) {
      debugPrint('Error getting playlist details: $e');
      return null;
    }
  }
}

class PlaylistDetails {
  final Playlist playlist;
  final List<Track> tracks;

  PlaylistDetails({required this.playlist, required this.tracks});
}
