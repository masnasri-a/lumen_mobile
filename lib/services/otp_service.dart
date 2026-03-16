import 'package:dio/dio.dart';
import 'api_client.dart';

class OtpService {
  final _dio = ApiClient.instance.dio;

  /// Send (or resend) OTP to the given email.
  Future<void> sendOtp(String email) async {
    try {
      await _dio.post('/auth/send-otp', data: {'email': email});
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  /// Verify the 6-digit OTP code for the given email.
  Future<void> verifyOtp(String email, String code) async {
    try {
      await _dio.post('/auth/verify-otp', data: {
        'email': email,
        'code': code,
      });
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  String _parseError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      return data['error']?.toString() ??
          data['message']?.toString() ??
          'Terjadi kesalahan';
    }
    return 'Terjadi kesalahan, coba lagi';
  }
}
