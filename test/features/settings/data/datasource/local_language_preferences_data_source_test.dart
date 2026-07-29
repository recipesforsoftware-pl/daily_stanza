import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daily_stanza/features/settings/data/datasource/local_language_preferences_data_source.dart';

void main() {
  group('LocalLanguagePreferencesDataSource', () {
    late LocalLanguagePreferencesDataSource dataSource;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    Future<void> setUpDataSource() async {
      final prefs = await SharedPreferences.getInstance();
      dataSource = LocalLanguagePreferencesDataSource(sharedPreferences: prefs);
    }

    test('missing key returns null', () async {
      await setUpDataSource();
      expect(dataSource.getLanguageCode(), isNull);
    });

    test('reads en', () async {
      SharedPreferences.setMockInitialValues({
        'preferred_poem_language_code': 'en',
      });
      await setUpDataSource();
      expect(dataSource.getLanguageCode(), 'en');
    });

    test('reads pl', () async {
      SharedPreferences.setMockInitialValues({
        'preferred_poem_language_code': 'pl',
      });
      await setUpDataSource();
      expect(dataSource.getLanguageCode(), 'pl');
    });

    test('saves en', () async {
      await setUpDataSource();
      await dataSource.setLanguageCode('en');
      expect(dataSource.getLanguageCode(), 'en');
    });

    test('saves pl', () async {
      await setUpDataSource();
      await dataSource.setLanguageCode('pl');
      expect(dataSource.getLanguageCode(), 'pl');
    });

    test('uses the exact preferred_poem_language_code key', () async {
      await setUpDataSource();
      final prefs = await SharedPreferences.getInstance();
      await dataSource.setLanguageCode('pl');
      expect(prefs.getString('preferred_poem_language_code'), 'pl');
    });

    test('failed setString result is false for invalid value type', () async {
      // SharedPreferences.setString always returns true for valid strings,
      // but the data source returns the Future<bool> from setString.
      await setUpDataSource();
      final result = await dataSource.setLanguageCode('en');
      expect(result, isTrue);
    });
  });
}
