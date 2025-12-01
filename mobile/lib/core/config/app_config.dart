/// Application Configuration
/// Centralized configuration for API endpoints and app settings

class AppConfig {
  // API Configuration
  static const String baseUrl = 'http://localhost:8000';
  static const String apiVersion = 'v1';
  static const String apiBaseUrl = '$baseUrl/api/$apiVersion';
  
  // Endpoints
  static const String authBase = '$apiBaseUrl/auth';
  static const String casesBase = '$apiBaseUrl/cases';
  static const String consultationsBase = '$apiBaseUrl/consultations';
  static const String filesBase = '$apiBaseUrl/files';
  static const String schedulingBase = '$apiBaseUrl/scheduling';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['image/jpeg', 'image/png', 'image/jpg'];
  
  // App Info
  static const String appName = 'GlobalHealth Connect';
  static const String appVersion = '1.0.0';
}
