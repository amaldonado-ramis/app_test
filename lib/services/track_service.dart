import 'dart:convert';
import 'package:echostream/models/stream_info.dart';
import 'package:echostream/models/track.dart';
import 'package:echostream/services/api_client.dart';
import 'package:flutter/foundation.dart';

class TrackService {
  final ApiClient _client = ApiClient();
  final Map<int, StreamInfo> _streamCache = {};

  Future<StreamInfo?> getStreamInfo(int trackId, {String quality = 'LOSSLESS'}) async {
    if (_streamCache.containsKey(trackId)) {
      final cached = _streamCache[trackId]!;
      if (!cached.isExpired) {
        return cached;
      }
    }

    try {
      final response = await _client.get('/track/?id=$trackId&quality=$quality');
      
      dynamic data = response;
      if (data is Map && data.containsKey('data')) {
        data = data['data'];
      }
      if (data is List && data.isNotEmpty) {
        data = data.first;
      }

      if (data is! Map<String, dynamic>) {
        debugPrint('Invalid track response format');
        return null;
      }

      String? streamUrl;

      if (data['OriginalTrackUrl'] != null) {
        streamUrl = data['OriginalTrackUrl'] as String;
      } else if (data['manifest'] != null) {
        streamUrl = _decodeManifest(data['manifest'] as String);
      }

      if (streamUrl == null || streamUrl.isEmpty) {
        debugPrint('Could not resolve stream URL for track $trackId');
        return null;
      }

      final streamInfo = StreamInfo(
        url: streamUrl,
        quality: quality,
      );

      _streamCache[trackId] = streamInfo;
      return streamInfo;
    } catch (e) {
      debugPrint('Error fetching stream info: $e');
      return null;
    }
  }

  String? _decodeManifest(String manifest) {
    try {
      final decoded = utf8.decode(base64.decode(manifest));
      
      try {
        final json = jsonDecode(decoded) as Map<String, dynamic>;
        if (json['urls'] != null && json['urls'] is List) {
          final urls = json['urls'] as List;
          if (urls.isNotEmpty) {
            return urls.first as String;
          }
        }
      } catch (_) {
        final urlMatch = RegExp(r'https://[^\s"]+').firstMatch(decoded);
        if (urlMatch != null) {
          return urlMatch.group(0);
        }
      }
    } catch (e) {
      debugPrint('Error decoding manifest: $e');
    }
    return null;
  }

  Future<Track?> getTrackMetadata(int trackId) async {
    try {
      final response = await _client.get('/track/?id=$trackId&quality=LOSSLESS');
      
      dynamic data = response;
      if (data is Map && data.containsKey('data')) {
        data = data['data'];
      }
      if (data is List && data.isNotEmpty) {
        data = data.first;
      }

      if (data is! Map<String, dynamic>) {
        return null;
      }

      return Track.fromJson(data);
    } catch (e) {
      debugPrint('Error fetching track metadata: $e');
      return null;
    }
  }

  void clearCache() {
    _streamCache.clear();
  }
}
