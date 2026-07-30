import 'package:shared_preferences/shared_preferences.dart';

class LocalOnboardingDataSource {
  LocalOnboardingDataSource({
    required SharedPreferences sharedPreferences,
  }) : _prefs = sharedPreferences;

  final SharedPreferences _prefs;

  static const String onboardingCompletedKey = 'onboarding_completed';

  /// Returns whether onboarding has been completed, or null when the key
  /// is missing.
  bool? getOnboardingCompleted() {
    return _prefs.containsKey(onboardingCompletedKey)
        ? _prefs.getBool(onboardingCompletedKey)
        : null;
  }

  /// Persists that onboarding has been completed.
  Future<bool> setOnboardingCompleted() async {
    return _prefs.setBool(onboardingCompletedKey, true);
  }
}
