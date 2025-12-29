import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:rhapsody/models/track.dart';
import 'package:rhapsody/models/stream_info.dart';
import 'package:rhapsody/services/api/tidal_api_client.dart';
import 'package:rhapsody/services/api/search_normalizer.dart';

class TrackApi {
  final TidalApiClient _client;

  TrackApi(this._client);

  Future<List<Track>> searchTracks(String query) async {
    try {
      final response = await _client.get('/search/', queryParams: {'s': query});
      final items = SearchNormalizer.extractItems(response, entityType: 'track');
      return items.map((json) => Track.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error searching tracks: $e');
      return [];
    }
  }

  Future<Track?> getTrack(int trackId) async {
    try {
      final response = await _client.get('/track/', queryParams: {
        'id': trackId.toString(),
        'quality': 'LOSSLESS',
      });
      
      if (response is Map && response.containsKey('data')) {
        final data = response['data'];
        if (data != null && data is Map) {
           // Ensure ID is present if not already
           if (!data.containsKey('id')) {
             data['id'] = trackId;
           }
           return Track.fromJson(Map<String, dynamic>.from(data));
        }
      }

      // Fallback: Use SearchNormalizer if 'data' block is missing or structure is different
      final items = SearchNormalizer.extractItems(response, entityType: 'track');
      
      if (items.isNotEmpty) {
        final exactMatch = items.firstWhere(
          (item) => item['id'].toString() == trackId.toString(),
          orElse: () => items.first,
        );
        return Track.fromJson(exactMatch);
      }

      debugPrint('getTrack($trackId) - No track found in response');
      return null;
    } catch (e) {
      debugPrint('Error getting track details: $e');
      return null;
    }
  }

  Future<StreamInfo?> getStreamInfo(int trackId) async {
    try {
      final response = await _client.get('/track/', queryParams: {
        'id': trackId.toString(),
        'quality': 'LOSSLESS',
      });

      dynamic trackData;
      // Prioritize the 'data' field structure
      if (response is Map && response.containsKey('data')) {
        trackData = response['data'];
      } else {
        trackData = response;
      }
      
      if (trackData is List && trackData.isNotEmpty) {
        trackData = trackData[0];
      }

      if (trackData is! Map<String, dynamic>) {
        debugPrint('Invalid track data structure');
        return null;
      }

      // Check for direct streamUrl (New API structure)
      if (trackData.containsKey('streamUrl') && trackData['streamUrl'] != null) {
        return StreamInfo(
          url: trackData['streamUrl'],
          quality: trackData['quality']?.toString() ?? 'LOSSLESS',
        );
      }

      // Fallback: Check for OriginalTrackUrl
      if (trackData.containsKey('OriginalTrackUrl') && trackData['OriginalTrackUrl'] != null) {
        return StreamInfo(
          url: trackData['OriginalTrackUrl'],
          quality: 'FLAC',
        );
      }

      // Fallback: Check for manifest
      if (trackData.containsKey('manifest')) {
        final manifest = trackData['manifest'];
        try {
          final decoded = utf8.decode(base64.decode(manifest));
          
          try {
            final manifestJson = json.decode(decoded);
            if (manifestJson is Map && manifestJson.containsKey('urls')) {
              final urls = manifestJson['urls'] as List;
              if (urls.isNotEmpty) {
                return StreamInfo(
                  url: urls[0],
                  quality: trackData['audioQuality'],
                );
              }
            }
          } catch (_) {
            final urlRegex = RegExp(r'https://[^\s<>"]+');
            final match = urlRegex.firstMatch(decoded);
            if (match != null) {
              return StreamInfo(
                url: match.group(0)!,
                quality: trackData['audioQuality'],
              );
            }
          }
        } catch (e) {
          debugPrint('Error decoding manifest: $e');
        }
      }

      debugPrint('Could not resolve stream URL for track $trackId');
      return null;
    } catch (e) {
      debugPrint('Error getting stream info: $e');
      return null;
    }
  }
}
