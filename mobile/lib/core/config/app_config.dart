class AppConfig {
  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.globalhealthconnect.com',
  );
  
  // AWS S3 Configuration
  static const String s3Bucket = String.fromEnvironment(
    'S3_BUCKET',
    defaultValue: 'globalhealth-connect-files',
  );
  
  static const String s3Region = String.fromEnvironment(
    'S3_REGION',
    defaultValue: 'us-east-1',
  );
  
  // Agora.io Configuration
  static const String agoraAppId = String.fromEnvironment(
    'AGORA_APP_ID',
    defaultValue: '',
  );
  
  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enableImageQualityCheck = true;
  static const int maxFileSizeMB = 100;
  static const int consultationDurationMinutes = 10;
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 10);
}

