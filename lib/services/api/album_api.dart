import 'package:flutter/foundation.dart';
import 'package:rhapsody/models/album.dart';
import 'package:rhapsody/models/track.dart';
import 'package:rhapsody/services/api/tidal_api_client.dart';
import 'package:rhapsody/services/api/search_normalizer.dart';

class AlbumApi {
  final TidalApiClient _client;

  AlbumApi(this._client);

  Future<List<Album>> searchAlbums(String query) async {
    try {
      final response = await _client.get('/search/', queryParams: {'al': query});
      final items = SearchNormalizer.extractItems(response, entityType: 'album');
      return items.map((json) => Album.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error searching albums: $e');
      return [];
    }
  }

  Future<AlbumDetails?> getAlbumDetails(String albumId) async {
    try {
      final response = await _client.get('/album/', queryParams: {'id': albumId});
      
      dynamic albumData = response;
      if (albumData is Map && albumData.containsKey('data')) {
        albumData = albumData['data'];
      }

      if (albumData is! Map<String, dynamic>) {
        debugPrint('Invalid album data structure');
        return null;
      }

      Album album;
      try {
        album = Album.fromJson(albumData);
      } catch (e) {
        debugPrint('Error parsing album metadata: $e');
        album = Album(
          id: albumId,
          title: albumData['title'] ?? 'Unknown Album',
          numberOfTracks: 0,
        );
      }

      final trackItems = SearchNormalizer.extractTracksFromAny(albumData);
      final tracks = trackItems.map((json) {
        try {
          return Track.fromJson(json);
        } catch (e) {
          debugPrint('Error parsing track: $e');
          return null;
        }
      }).whereType<Track>().toList();

      if (album.artists == null && tracks.isNotEmpty) {
        album = album.copyWith(artists: tracks.first.artists ?? [tracks.first.artist]);
      }
      if (album.releaseDate == null && tracks.isNotEmpty && tracks.first.album?.releaseDate != null) {
        album = album.copyWith(releaseDate: tracks.first.album!.releaseDate);
      }

      return AlbumDetails(album: album, tracks: tracks);
    } catch (e) {
      debugPrint('Error getting album details: $e');
      return null;
    }
  }
}

class AlbumDetails {
  final Album album;
  final List<Track> tracks;

  AlbumDetails({required this.album, required this.tracks});
}
