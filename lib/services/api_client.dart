import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiClient {
  static const String baseUrl = 'https://tidal.kinoplus.online';
  final Map<String, CachedResponse> _cache = {};

  Future<dynamic> get(String endpoint) async {
    final url = '$baseUrl$endpoint';
    
    if (_cache.containsKey(url)) {
      final cached = _cache[url]!;
      if (!cached.isExpired) {
        return cached.data;
      }
    }

    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _cache[url] = CachedResponse(data);
        return data;
      } else {
        debugPrint('API Error: ${response.statusCode} for $url');
        throw ApiException('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Network error: $e');
      throw ApiException('Network error: $e');
    }
  }

  dynamic findItems(dynamic json) {
    if (json == null) return null;
    
    if (json is Map<String, dynamic>) {
      if (json.containsKey('items') && json['items'] is List) {
        return json['items'];
      }
      
      for (var value in json.values) {
        final result = findItems(value);
        if (result != null) return result;
      }
    } else if (json is List) {
      for (var item in json) {
        final result = findItems(item);
        if (result != null) return result;
      }
    }
    
    return null;
  }

  void clearCache() {
    _cache.clear();
  }
}

class CachedResponse {
  final dynamic data;
  final DateTime timestamp;

  CachedResponse(this.data) : timestamp = DateTime.now();

  bool get isExpired {
    final age = DateTime.now().difference(timestamp);
    return age.inMinutes > 5;
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
