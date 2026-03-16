class AppConfig {
  static const String baseUrl = 'http://43.157.202.18:8080/api/v1';

  // Timeout
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
