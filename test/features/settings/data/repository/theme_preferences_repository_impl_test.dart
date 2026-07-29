import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daily_stanza/features/settings/data/datasource/local_theme_preferences_data_source.dart';
import 'package:daily_stanza/features/settings/data/repository/theme_preferences_repository_impl.dart';
import 'package:daily_stanza/features/settings/domain/model/theme_preference.dart';
import 'package:daily_stanza/features/settings/domain/repository/theme_preferences_repository.dart';

void main() {
  group('ThemePreferencesRepositoryImpl', () {
    late ThemePreferencesRepository repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    Future<void> setUpRepository() async {
      final prefs = await SharedPreferences.getInstance();
      final dataSource = LocalThemePreferencesDataSource(
        sharedPreferences: prefs,
      );
      repository = ThemePreferencesRepositoryImpl(dataSource: dataSource);
    }

    test('missing value resolves to System', () async {
      await setUpRepository();
      expect(await repository.getPreferredTheme(), ThemePreference.system);
    });

    test('blank value resolves to System', () async {
      SharedPreferences.setMockInitialValues({'preferred_theme_mode': ''});
      await setUpRepository();
      expect(await repository.getPreferredTheme(), ThemePreference.system);
    });

    test('unsupported value resolves to System', () async {
      SharedPreferences.setMockInitialValues({'preferred_theme_mode': 'oled'});
      await setUpRepository();
      expect(await repository.getPreferredTheme(), ThemePreference.system);
    });

    test('system resolves to ThemePreference.system', () async {
      SharedPreferences.setMockInitialValues({
        'preferred_theme_mode': 'system',
      });
      await setUpRepository();
      expect(await repository.getPreferredTheme(), ThemePreference.system);
    });

    test('light resolves to ThemePreference.light', () async {
      SharedPreferences.setMockInitialValues({'preferred_theme_mode': 'light'});
      await setUpRepository();
      expect(await repository.getPreferredTheme(), ThemePreference.light);
    });

    test('dark resolves to ThemePreference.dark', () async {
      SharedPreferences.setMockInitialValues({'preferred_theme_mode': 'dark'});
      await setUpRepository();
      expect(await repository.getPreferredTheme(), ThemePreference.dark);
    });

    test('setPreferredTheme stores the correct code', () async {
      await setUpRepository();
      await repository.setPreferredTheme(ThemePreference.dark);
      expect(await repository.getPreferredTheme(), ThemePreference.dark);
      await repository.setPreferredTheme(ThemePreference.light);
      expect(await repository.getPreferredTheme(), ThemePreference.light);
      await repository.setPreferredTheme(ThemePreference.system);
      expect(await repository.getPreferredTheme(), ThemePreference.system);
    });

    test('write failure propagates safely', () async {
      await setUpRepository();
      await expectLater(
        repository.setPreferredTheme(ThemePreference.system),
        completes,
      );
    });
  });
}
