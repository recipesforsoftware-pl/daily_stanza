import 'package:daily_stanza/features/settings/domain/model/poem_language.dart';

abstract interface class LanguagePreferencesRepository {
  Future<PoemLanguage> getPreferredLanguage();

  Future<void> setPreferredLanguage(PoemLanguage language);
}
