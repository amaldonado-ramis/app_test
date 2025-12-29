import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class TidalApiClient {
  static const String baseUrl = 'https://tidal.kinoplus.online';
  final http.Client _client = http.Client();

  Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final finalUri = queryParams != null && queryParams.isNotEmpty
          ? uri.replace(queryParameters: queryParams)
          : uri;

      debugPrint('API Request: $finalUri');
      
      final response = await _client.get(finalUri);
      
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded;
      } else {
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('API request failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('API Exception: $e');
      rethrow;
    }
  }

  void dispose() {
    _client.close();
  }
}
