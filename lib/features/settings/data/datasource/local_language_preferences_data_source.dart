import 'package:shared_preferences/shared_preferences.dart';

class LocalLanguagePreferencesDataSource {
  LocalLanguagePreferencesDataSource({
    required SharedPreferences sharedPreferences,
  }) : _prefs = sharedPreferences;

  final SharedPreferences _prefs;

  static const String preferredPoemLanguageCodeKey =
      'preferred_poem_language_code';

  /// Returns the stored language code or null when the key is missing.
  String? getLanguageCode() {
    return _prefs.getString(preferredPoemLanguageCodeKey);
  }

  /// Persists the given language code.
  Future<bool> setLanguageCode(String code) async {
    return _prefs.setString(preferredPoemLanguageCodeKey, code);
  }
}
