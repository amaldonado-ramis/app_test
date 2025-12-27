import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:echobeat/config/api_config.dart';

class ApiClient {
  final Dio _dio;

  ApiClient()
      : _dio = Dio(BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          headers: {'Content-Type': 'application/json'},
        )) {
    // Interceptor para añadir la cookie 'session' a cada request
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Cookie'] = '${ApiConfig.cookieName}=${ApiConfig.sessionToken}';
        handler.next(options);
      },
      onError: (DioError e, handler) {
        debugPrint('Dio error: ${e.response?.statusCode} - ${e.message}');
        handler.next(e);
      },
    ));
  }

  Future<Map<String, dynamic>> get(String endpoint, {bool requiresAuth = true}) async {
    try {
      final response = await _dio.get(endpoint);

      if (response.statusCode == 200) {
        if (response.data is Map<String, dynamic>) {
          return response.data;
        } else {
          return json.decode(response.data.toString()) as Map<String, dynamic>;
        }
      } else {
        debugPrint('API Error: ${response.statusCode} - ${response.data}');
        throw ApiException(
          'Request failed with status: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('API Client Error: $e');
      rethrow;
    }
  }

  void dispose() {
    _dio.close();
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() =>
      'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}