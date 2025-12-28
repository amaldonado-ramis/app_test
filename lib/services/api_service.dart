import 'package:flutter/foundation.dart';
import 'package:echobeat/models/track.dart';
import 'package:echobeat/models/album.dart';
import 'package:echobeat/models/pagination.dart';
import 'package:echobeat/services/api_client.dart';

class ApiService {
  final ApiClient _client = ApiClient();

  Future<SearchTracksResult> searchTracks(String query, {int offset = 0}) async {
    try {
      final data = await _client.get(
        '/search?q=${Uri.encodeComponent(query)}&offset=$offset&type=track',
      );

      final tracks = (data['tracks'] as List?)
          ?.map((json) => Track.fromJson(json as Map<String, dynamic>))
          .toList() ?? [];

      final pagination = data['pagination'] != null
          ? Pagination.fromJson(data['pagination'])
          : Pagination(offset: 0, limit: 0, total: 0, hasMore: false, returned: 0);

      return SearchTracksResult(tracks: tracks, pagination: pagination);
    } catch (e) {
      debugPrint('Error searching tracks: $e');
      rethrow;
    }
  }

  Future<SearchAlbumsResult> searchAlbums(String query, {int offset = 0}) async {
    try {
      final data = await _client.get(
        '/search?q=${Uri.encodeComponent(query)}&offset=$offset&type=album',
      );

      final albums = (data['albums'] as List?)
          ?.map((json) => Album.fromJson(json as Map<String, dynamic>))
          .toList() ?? [];

      final pagination = data['pagination'] != null
          ? Pagination.fromJson(data['pagination'])
          : Pagination(offset: 0, limit: 0, total: 0, hasMore: false, returned: 0);

      return SearchAlbumsResult(albums: albums, pagination: pagination);
    } catch (e) {
      debugPrint('Error searching albums: $e');
      rethrow;
    }
  }

  Future<String> getStreamUrl(int trackId) async {
    try {
      final data = await _client.get(
        '/stream?trackId=$trackId',
      );

      return data['url'] as String? ?? '';
    } catch (e) {
      debugPrint('Error getting stream URL: $e');
      rethrow;
    }
  }

  void dispose() => _client.dispose();
}

class SearchTracksResult {
  final List<Track> tracks;
  final Pagination pagination;

  SearchTracksResult({required this.tracks, required this.pagination});
}

class SearchAlbumsResult {
  final List<Album> albums;
  final Pagination pagination;

  SearchAlbumsResult({required this.albums, required this.pagination});
}
