import 'package:shared_preferences/shared_preferences.dart';

/// Persistent local settings (non-sensitive per-device preferences).
/// Stores the Gemini API key locally — never sent to Firestore.
class AppSettings {
  AppSettings._();
  static final AppSettings instance = AppSettings._();

  static const String _geminiApiKeyPref = 'gemini_api_key';
  static const String _aiEnabledPref = 'ai_analysis_enabled';

  /// Read the Gemini API key from SharedPreferences.
  Future<String?> getGeminiApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString(_geminiApiKeyPref);
    return (key != null && key.trim().isNotEmpty) ? key.trim() : null;
  }

  /// Save the Gemini API key to SharedPreferences.
  Future<void> setGeminiApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_geminiApiKeyPref, apiKey.trim());
  }

  /// Remove the stored Gemini API key.
  Future<void> clearGeminiApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_geminiApiKeyPref);
  }

  /// Whether AI analysis is enabled by the user. Defaults to true.
  Future<bool> getAiEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_aiEnabledPref) ?? true;
  }

  /// Persist the AI enabled setting.
  Future<void> setAiEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_aiEnabledPref, enabled);
  }
}
