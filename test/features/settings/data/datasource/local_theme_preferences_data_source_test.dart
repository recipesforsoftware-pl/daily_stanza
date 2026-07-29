import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daily_stanza/features/settings/data/datasource/local_theme_preferences_data_source.dart';

void main() {
  group('LocalThemePreferencesDataSource', () {
    late LocalThemePreferencesDataSource dataSource;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    Future<void> setUpDataSource() async {
      final prefs = await SharedPreferences.getInstance();
      dataSource = LocalThemePreferencesDataSource(sharedPreferences: prefs);
    }

    test('missing key returns null', () async {
      await setUpDataSource();
      expect(dataSource.getThemeModeCode(), isNull);
    });

    test('reads system', () async {
      SharedPreferences.setMockInitialValues({
        'preferred_theme_mode': 'system',
      });
      await setUpDataSource();
      expect(dataSource.getThemeModeCode(), 'system');
    });

    test('reads light', () async {
      SharedPreferences.setMockInitialValues({'preferred_theme_mode': 'light'});
      await setUpDataSource();
      expect(dataSource.getThemeModeCode(), 'light');
    });

    test('reads dark', () async {
      SharedPreferences.setMockInitialValues({'preferred_theme_mode': 'dark'});
      await setUpDataSource();
      expect(dataSource.getThemeModeCode(), 'dark');
    });

    test('saves system', () async {
      await setUpDataSource();
      await dataSource.setThemeModeCode('system');
      expect(dataSource.getThemeModeCode(), 'system');
    });

    test('saves light', () async {
      await setUpDataSource();
      await dataSource.setThemeModeCode('light');
      expect(dataSource.getThemeModeCode(), 'light');
    });

    test('saves dark', () async {
      await setUpDataSource();
      await dataSource.setThemeModeCode('dark');
      expect(dataSource.getThemeModeCode(), 'dark');
    });

    test('uses the exact preferred_theme_mode key', () async {
      await setUpDataSource();
      final prefs = await SharedPreferences.getInstance();
      await dataSource.setThemeModeCode('dark');
      expect(prefs.getString('preferred_theme_mode'), 'dark');
    });

    test('does not overwrite preferred_poem_language_code', () async {
      SharedPreferences.setMockInitialValues({
        'preferred_poem_language_code': 'pl',
      });
      await setUpDataSource();
      await dataSource.setThemeModeCode('dark');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('preferred_poem_language_code'), 'pl');
      expect(prefs.getString('preferred_theme_mode'), 'dark');
    });

    test(
      'failed setString result follows SharedPreferences contract',
      () async {
        await setUpDataSource();
        final result = await dataSource.setThemeModeCode('system');
        expect(result, isTrue);
      },
    );
  });
}
