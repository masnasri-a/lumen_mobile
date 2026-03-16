import 'package:dio/dio.dart';
import '../models/auth_response.dart';
import '../models/user_model.dart';
import 'api_client.dart';

class AuthService {
  final _dio = ApiClient.instance.dio;

  // ── Register ────────────────────────────────────────────────────────────────

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final resp = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });
      final data = resp.data['data'] as Map<String, dynamic>;
      final result = AuthResponse.fromJson(data);
      await ApiClient.saveTokens(result.accessToken, result.refreshToken);
      return result;
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  // ── Login ───────────────────────────────────────────────────────────────────

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final resp = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final data = resp.data['data'] as Map<String, dynamic>;
      final result = AuthResponse.fromJson(data);
      await ApiClient.saveTokens(result.accessToken, result.refreshToken);
      return result;
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  // ── Google Login ─────────────────────────────────────────────────────────────

  Future<AuthResponse> loginWithGoogle(String idToken) async {
    try {
      final resp = await _dio.post('/auth/google', data: {'id_token': idToken});
      final data = resp.data['data'] as Map<String, dynamic>;
      final result = AuthResponse.fromJson(data);
      await ApiClient.saveTokens(result.accessToken, result.refreshToken);
      return result;
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  // ── Logout ───────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {
    } finally {
      await ApiClient.clearTokens();
    }
  }

  // ── Update profile ───────────────────────────────────────────────────────────

  Future<UserModel> updateProfile({required String name}) async {
    try {
      final resp = await _dio.put('/me', data: {'name': name});
      return UserModel.fromJson(resp.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  // ── Get current user ─────────────────────────────────────────────────────────

  Future<UserModel> getMe() async {
    try {
      final resp = await _dio.get('/me');
      return UserModel.fromJson(resp.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  // ── Helper ────────────────────────────────────────────────────────────────────

  String _parseError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      return data['error']?.toString() ?? data['message']?.toString() ?? 'Terjadi kesalahan';
    }
    return 'Terjadi kesalahan, coba lagi';
  }
}
