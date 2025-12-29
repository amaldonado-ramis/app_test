import 'package:echostream/models/album.dart';
import 'package:echostream/models/artist.dart';
import 'package:echostream/models/playlist_preview.dart';
import 'package:echostream/models/track.dart';
import 'package:echostream/services/api_client.dart';
import 'package:flutter/foundation.dart';

class SearchService {
  final ApiClient _client = ApiClient();

  Future<List<Track>> searchTracks(String query) async {
    if (query.isEmpty) return [];
    
    try {
      final response = await _client.get('/search/?s=${Uri.encodeComponent(query)}');
      final items = _client.findItems(response);
      
      if (items == null || items is! List) return [];
      
      return items
          .where((item) => item is Map<String, dynamic> && item['id'] != null)
          .map((item) {
            try {
              return Track.fromJson(item as Map<String, dynamic>);
            } catch (e) {
              debugPrint('Error parsing track: $e');
              return null;
            }
          })
          .whereType<Track>()
          .toList();
    } catch (e) {
      debugPrint('Search tracks error: $e');
      return [];
    }
  }

  Future<List<Album>> searchAlbums(String query) async {
    if (query.isEmpty) return [];
    
    try {
      final response = await _client.get('/search/?al=${Uri.encodeComponent(query)}');
      final items = _client.findItems(response);
      
      if (items == null || items is! List) return [];
      
      return items
          .where((item) => item is Map<String, dynamic> && item['id'] != null)
          .map((item) {
            try {
              return Album.fromJson(item as Map<String, dynamic>);
            } catch (e) {
              debugPrint('Error parsing album: $e');
              return null;
            }
          })
          .whereType<Album>()
          .toList();
    } catch (e) {
      debugPrint('Search albums error: $e');
      return [];
    }
  }

  Future<List<Artist>> searchArtists(String query) async {
    if (query.isEmpty) return [];
    
    try {
      final response = await _client.get('/search/?a=${Uri.encodeComponent(query)}');
      final items = _client.findItems(response);
      
      if (items == null || items is! List) return [];
      
      return items
          .where((item) => item is Map<String, dynamic> && item['id'] != null)
          .map((item) {
            try {
              return Artist.fromJson(item as Map<String, dynamic>);
            } catch (e) {
              debugPrint('Error parsing artist: $e');
              return null;
            }
          })
          .whereType<Artist>()
          .toList();
    } catch (e) {
      debugPrint('Search artists error: $e');
      return [];
    }
  }

  Future<List<PlaylistPreview>> searchPlaylists(String query) async {
    if (query.isEmpty) return [];
    
    try {
      final response = await _client.get('/search/?p=${Uri.encodeComponent(query)}');
      final items = _client.findItems(response);
      
      if (items == null || items is! List) return [];
      
      return items
          .where((item) => item is Map<String, dynamic> && item['id'] != null)
          .map((item) {
            try {
              return PlaylistPreview.fromJson(item as Map<String, dynamic>);
            } catch (e) {
              debugPrint('Error parsing playlist: $e');
              return null;
            }
          })
          .whereType<PlaylistPreview>()
          .toList();
    } catch (e) {
      debugPrint('Search playlists error: $e');
      return [];
    }
  }
}
