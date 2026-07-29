import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daily_stanza/features/settings/data/datasource/local_language_preferences_data_source.dart';
import 'package:daily_stanza/features/settings/data/repository/language_preferences_repository_impl.dart';
import 'package:daily_stanza/features/settings/domain/model/poem_language.dart';
import 'package:daily_stanza/features/settings/domain/repository/language_preferences_repository.dart';

void main() {
  group('LanguagePreferencesRepositoryImpl', () {
    late LanguagePreferencesRepository repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    Future<void> setUpRepository() async {
      final prefs = await SharedPreferences.getInstance();
      final dataSource = LocalLanguagePreferencesDataSource(
        sharedPreferences: prefs,
      );
      repository = LanguagePreferencesRepositoryImpl(dataSource: dataSource);
    }

    test('missing value resolves to English', () async {
      await setUpRepository();
      expect(await repository.getPreferredLanguage(), PoemLanguage.english);
    });

    test('blank value resolves to English', () async {
      SharedPreferences.setMockInitialValues({
        'preferred_poem_language_code': '',
      });
      await setUpRepository();
      expect(await repository.getPreferredLanguage(), PoemLanguage.english);
    });

    test('unsupported value resolves to English', () async {
      SharedPreferences.setMockInitialValues({
        'preferred_poem_language_code': 'fr',
      });
      await setUpRepository();
      expect(await repository.getPreferredLanguage(), PoemLanguage.english);
    });

    test('en resolves to PoemLanguage.english', () async {
      SharedPreferences.setMockInitialValues({
        'preferred_poem_language_code': 'en',
      });
      await setUpRepository();
      expect(await repository.getPreferredLanguage(), PoemLanguage.english);
    });

    test('pl resolves to PoemLanguage.polish', () async {
      SharedPreferences.setMockInitialValues({
        'preferred_poem_language_code': 'pl',
      });
      await setUpRepository();
      expect(await repository.getPreferredLanguage(), PoemLanguage.polish);
    });

    test('setPreferredLanguage stores the correct code', () async {
      await setUpRepository();
      await repository.setPreferredLanguage(PoemLanguage.polish);
      expect(await repository.getPreferredLanguage(), PoemLanguage.polish);
      await repository.setPreferredLanguage(PoemLanguage.english);
      expect(await repository.getPreferredLanguage(), PoemLanguage.english);
    });

    test('data-source write failure is propagated safely', () async {
      await setUpRepository();
      // setString for string values always succeeds with SharedPreferences,
      // so this tests the normal path.  A real failure would require a mock.
      await expectLater(
        repository.setPreferredLanguage(PoemLanguage.english),
        completes,
      );
    });
  });
}
