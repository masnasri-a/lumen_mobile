import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;
  static const _storage = FlutterSecureStorage();

  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';

  ApiClient._() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final token = await _storage.read(key: _keyAccessToken);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (_) {
          // Secure storage not available (e.g. after hot restart), proceed without token
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshed = await _tryRefresh();
          if (refreshed) {
            // Retry original request with new token
            try {
              final token = await _storage.read(key: _keyAccessToken);
              error.requestOptions.headers['Authorization'] = 'Bearer $token';
            } catch (_) {}
            final retryResponse = await _dio.fetch(error.requestOptions);
            return handler.resolve(retryResponse);
          }
        }
        handler.next(error);
      },
    ));
  }

  static ApiClient get instance {
    _instance ??= ApiClient._();
    return _instance!;
  }

  Dio get dio => _dio;

  // ── Token management ────────────────────────────────────────────────────────

  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    await Future.wait([
      _storage.write(key: _keyAccessToken, value: accessToken),
      _storage.write(key: _keyRefreshToken, value: refreshToken),
    ]);
  }

  static Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyRefreshToken),
    ]);
  }

  static Future<bool> hasToken() async {
    try {
      final token = await _storage.read(key: _keyAccessToken);
      return token != null && token.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _tryRefresh() async {
    try {
      final refreshToken = await _storage.read(key: _keyRefreshToken);
      if (refreshToken == null) return false;

      final resp = await Dio(BaseOptions(baseUrl: AppConfig.baseUrl))
          .post('/auth/refresh', data: {'refresh_token': refreshToken});

      final newToken = resp.data['data']['access_token'] as String?;
      if (newToken != null) {
        await _storage.write(key: _keyAccessToken, value: newToken);
        return true;
      }
    } catch (_) {}
    return false;
  }
}
