import 'package:shared_preferences/shared_preferences.dart';

/// Persistent local settings (non-sensitive per-device preferences).
class AppSettings {
  AppSettings._();
  static final AppSettings instance = AppSettings._();

  static const String _aiEnabledPref = 'ai_analysis_enabled';

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
