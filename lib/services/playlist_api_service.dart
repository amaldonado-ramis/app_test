import 'package:echostream/models/playlist_preview.dart';
import 'package:echostream/models/track.dart';
import 'package:echostream/services/api_client.dart';
import 'package:flutter/foundation.dart';

class PlaylistApiService {
  final ApiClient _client = ApiClient();

  Future<PlaylistDetails?> getPlaylistDetails(String playlistId) async {
    try {
      final response = await _client.get('/playlist/?id=$playlistId');
      
      dynamic data = response;
      if (data is Map && data.containsKey('data')) {
        data = data['data'];
      }

      if (data is! Map<String, dynamic>) {
        debugPrint('Invalid playlist response format');
        return null;
      }

      final playlist = PlaylistPreview.fromJson(data);
      
      final items = _client.findItems(data);
      List<Track> tracks = [];
      
      if (items != null && items is List) {
        tracks = items
            .where((item) => item is Map<String, dynamic> && item['id'] != null)
            .map((item) {
              try {
                return Track.fromJson(item as Map<String, dynamic>);
              } catch (e) {
                debugPrint('Error parsing track in playlist: $e');
                return null;
              }
            })
            .whereType<Track>()
            .toList();
      }

      return PlaylistDetails(playlist: playlist, tracks: tracks);
    } catch (e) {
      debugPrint('Error fetching playlist details: $e');
      return null;
    }
  }
}

class PlaylistDetails {
  final PlaylistPreview playlist;
  final List<Track> tracks;

  PlaylistDetails({
    required this.playlist,
    required this.tracks,
  });
}
