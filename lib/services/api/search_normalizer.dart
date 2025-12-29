import 'package:flutter/foundation.dart';

class SearchNormalizer {
  static List<Map<String, dynamic>> extractItems(dynamic json, {String? entityType}) {
    final results = <Map<String, dynamic>>[];
    _traverseJson(json, results, entityType);
    return results;
  }

  static void _traverseJson(dynamic node, List<Map<String, dynamic>> results, String? entityType) {
    if (node == null) return;

    if (node is Map<String, dynamic>) {
      if (node.containsKey('items') && node['items'] is List) {
        final items = node['items'] as List;
        for (var item in items) {
          if (item is Map<String, dynamic>) {
            if (entityType == null || _matchesEntityType(item, entityType)) {
              results.add(item);
            }
          }
        }
      }

      for (var value in node.values) {
        _traverseJson(value, results, entityType);
      }
    } else if (node is List) {
      for (var item in node) {
        _traverseJson(item, results, entityType);
      }
    }
  }

  static bool _matchesEntityType(Map<String, dynamic> item, String entityType) {
    switch (entityType) {
      case 'track':
        // Relaxed check: Some tracks might not have album info immediately available
        // But they definitely have title and duration
        return item.containsKey('title') && (item.containsKey('duration') || item.containsKey('trackNumber'));
      case 'album':
        return item.containsKey('numberOfTracks') && !item.containsKey('duration');
      case 'artist':
        return item.containsKey('name') && !item.containsKey('title');
      case 'playlist':
        return (item.containsKey('numberOfTracks') || item.containsKey('trackCount')) 
            && (item.containsKey('uuid') || item['type'] == 'PLAYLIST');
      default:
        return true;
    }
  }

  static List<Map<String, dynamic>> extractTracksFromAny(dynamic json) {
    final results = <Map<String, dynamic>>[];
    _extractSpecificEntity(json, results, (item) {
      // Must look like a track and NOT like an album or artist
      return item.containsKey('id') && 
             item.containsKey('duration') && 
             item.containsKey('title') &&
             !item.containsKey('numberOfTracks') && 
             !item.containsKey('type'); // type usually denotes 'ALBUM', 'ARTIST', 'PLAYLIST'. Tracks often don't have 'type' or it's 'TRACK'.
    });
    return results;
  }

  static List<Map<String, dynamic>> extractAlbumsFromAny(dynamic json) {
    final results = <Map<String, dynamic>>[];
    _extractSpecificEntity(json, results, (item) {
      return item.containsKey('id') && 
             (item.containsKey('numberOfTracks') || item['type'] == 'ALBUM' || item['type'] == 'EP' || item['type'] == 'SINGLE');
             // Removed strict !duration check because some APIs might return total duration for albums
    });
    return results;
  }

  static void _extractSpecificEntity(
    dynamic node, 
    List<Map<String, dynamic>> results,
    bool Function(Map<String, dynamic>) matcher
  ) {
    if (node == null) return;

    if (node is Map<String, dynamic>) {
      if (matcher(node)) {
        results.add(node);
        return;
      }

      for (var value in node.values) {
        _extractSpecificEntity(value, results, matcher);
      }
    } else if (node is List) {
      for (var item in node) {
        _extractSpecificEntity(item, results, matcher);
      }
    }
  }
}
