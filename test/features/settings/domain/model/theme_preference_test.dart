import 'package:flutter_test/flutter_test.dart';
import 'package:daily_stanza/features/settings/domain/model/theme_preference.dart';

void main() {
  group('ThemePreference', () {
    group('fromCode', () {
      test('null maps to system', () {
        expect(ThemePreference.fromCode(null), ThemePreference.system);
      });

      test('blank maps to system', () {
        expect(ThemePreference.fromCode(''), ThemePreference.system);
      });

      test('unsupported value maps to system', () {
        expect(ThemePreference.fromCode('unknown'), ThemePreference.system);
      });

      test('system maps to system', () {
        expect(ThemePreference.fromCode('system'), ThemePreference.system);
      });

      test('light maps to light', () {
        expect(ThemePreference.fromCode('light'), ThemePreference.light);
      });

      test('dark maps to dark', () {
        expect(ThemePreference.fromCode('dark'), ThemePreference.dark);
      });
    });

    group('codes', () {
      test('system code is system', () {
        expect(ThemePreference.system.code, 'system');
      });

      test('light code is light', () {
        expect(ThemePreference.light.code, 'light');
      });

      test('dark code is dark', () {
        expect(ThemePreference.dark.code, 'dark');
      });
    });
  });
}
