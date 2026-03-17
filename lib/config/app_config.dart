class AppConfig {
  static const String baseUrl = 'https://backend-lumen.nusarithm.id/api/v1';

  // Timeout
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
