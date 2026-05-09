/// Application constants
class AppConstants {
  // App metadata
  static const String appName = 'Hypnos Dream Journal';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  // Timeouts
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration shortTimeout = Duration(seconds: 10);

  // Firebase collections
  static const String usersCollection = 'users';
  static const String dreamsCollection = 'dreams';
  static const String insightsCollection = 'insights';
  static const String audioStoragePrefix = 'dreams/audio';

  // Audio recording
  static const int maxAudioDurationSeconds = 600; // 10 minutes
  static const int minAudioDurationSeconds = 3;

  // UI Constants
  static const int dreamTitleMaxLength = 100;
  static const int dreamDescriptionMaxLength = 5000;

  // Pagination
  static const int dreamsPageSize = 50;
  static const int insightsPageSize = 20;
}

/// Feature flags for gradual rollout
class FeatureFlags {
  static const bool enableAIAnalysis = true;
  static const bool enableBiometricAuth = true;
  static const bool enableSpeechToText = true;
  static const bool enableOfflineMode = true;
  static const bool enableAnalytics = false; // Privacy-first
}

/// Error messages for common scenarios
class ErrorMessages {
  static const String networkError =
      'Network connection error. Please check your internet connection.';
  static const String unknownError =
      'An unexpected error occurred. Please try again.';
  static const String authError =
      'Authentication failed. Please sign in again.';
  static const String invalidEmail = 'Please enter a valid email address.';
  static const String passwordTooShort =
      'Password must be at least 8 characters.';
  static const String firebaseNotInitialized =
      'Firebase is not initialized. Please restart the app.';
}
