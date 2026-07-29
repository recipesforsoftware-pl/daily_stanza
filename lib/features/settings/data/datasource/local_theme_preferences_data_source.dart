import 'package:shared_preferences/shared_preferences.dart';

class LocalThemePreferencesDataSource {
  LocalThemePreferencesDataSource({
    required SharedPreferences sharedPreferences,
  }) : _prefs = sharedPreferences;

  final SharedPreferences _prefs;

  static const String preferredThemeModeKey = 'preferred_theme_mode';

  /// Returns the stored theme mode code or null when the key is missing.
  String? getThemeModeCode() {
    return _prefs.getString(preferredThemeModeKey);
  }

  /// Persists the given theme mode code.
  Future<bool> setThemeModeCode(String code) async {
    return _prefs.setString(preferredThemeModeKey, code);
  }
}
