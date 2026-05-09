/// Application configuration
class AppConfig {
  // Build-specific configuration
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  /// Check if running in debug mode
  static bool get isDebug {
    return environment == 'development';
  }

  /// Check if running in production mode
  static bool get isProduction {
    return environment == 'production';
  }

  /// Check if running in staging mode
  static bool get isStaging {
    return environment == 'staging';
  }
}
