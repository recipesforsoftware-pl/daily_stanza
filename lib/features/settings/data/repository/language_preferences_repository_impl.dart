import 'package:daily_stanza/features/settings/data/datasource/local_language_preferences_data_source.dart';
import 'package:daily_stanza/features/settings/domain/model/poem_language.dart';
import 'package:daily_stanza/features/settings/domain/repository/language_preferences_repository.dart';

class LanguagePreferencesRepositoryImpl
    implements LanguagePreferencesRepository {
  const LanguagePreferencesRepositoryImpl({
    required LocalLanguagePreferencesDataSource dataSource,
  }) : _dataSource = dataSource;

  final LocalLanguagePreferencesDataSource _dataSource;

  @override
  Future<PoemLanguage> getPreferredLanguage() async {
    final code = _dataSource.getLanguageCode();
    return PoemLanguage.fromCode(code);
  }

  @override
  Future<void> setPreferredLanguage(PoemLanguage language) async {
    final result = await _dataSource.setLanguageCode(language.code);
    if (!result) {
      throw Exception('Failed to save language preference');
    }
  }
}
