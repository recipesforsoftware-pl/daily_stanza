import 'package:daily_stanza/features/settings/domain/model/theme_preference.dart';

abstract interface class ThemePreferencesRepository {
  Future<ThemePreference> getPreferredTheme();

  Future<void> setPreferredTheme(ThemePreference preference);
}
