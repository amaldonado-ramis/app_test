import 'package:echostream/models/album.dart';
import 'package:echostream/models/track.dart';
import 'package:echostream/services/api_client.dart';
import 'package:flutter/foundation.dart';

class AlbumService {
  final ApiClient _client = ApiClient();

  Future<AlbumDetails?> getAlbumDetails(String albumId) async {
    try {
      final response = await _client.get('/album/?id=$albumId');
      
      dynamic data = response;
      if (data is Map && data.containsKey('data')) {
        data = data['data'];
      }

      if (data is! Map<String, dynamic>) {
        debugPrint('Invalid album response format');
        return null;
      }

      Album album = Album.fromJson(data);
      
      final items = _client.findItems(data);
      List<Track> tracks = [];
      
      if (items != null && items is List) {
        tracks = items
            .where((item) => item is Map<String, dynamic> && item['id'] != null)
            .map((item) {
              try {
                final track = Track.fromJson(item as Map<String, dynamic>);
                if (track.album == null && album.cover != null) {
                  return track.copyWith(album: album);
                }
                return track;
              } catch (e) {
                debugPrint('Error parsing track in album: $e');
                return null;
              }
            })
            .whereType<Track>()
            .toList();
      }

      if (album.artist == null && tracks.isNotEmpty && tracks.first.artist != null) {
        album = album.copyWith(artist: tracks.first.artist);
      }

      return AlbumDetails(album: album, tracks: tracks);
    } catch (e) {
      debugPrint('Error fetching album details: $e');
      return null;
    }
  }
}

class AlbumDetails {
  final Album album;
  final List<Track> tracks;

  AlbumDetails({
    required this.album,
    required this.tracks,
  });
}
