import 'package:daily_stanza/features/settings/data/datasource/local_theme_preferences_data_source.dart';
import 'package:daily_stanza/features/settings/domain/model/theme_preference.dart';
import 'package:daily_stanza/features/settings/domain/repository/theme_preferences_repository.dart';

class ThemePreferencesRepositoryImpl implements ThemePreferencesRepository {
  const ThemePreferencesRepositoryImpl({
    required LocalThemePreferencesDataSource dataSource,
  }) : _dataSource = dataSource;

  final LocalThemePreferencesDataSource _dataSource;

  @override
  Future<ThemePreference> getPreferredTheme() async {
    final code = _dataSource.getThemeModeCode();
    return ThemePreference.fromCode(code);
  }

  @override
  Future<void> setPreferredTheme(ThemePreference preference) async {
    final result = await _dataSource.setThemeModeCode(preference.code);
    if (!result) {
      throw Exception('Failed to save theme preference');
    }
  }
}
