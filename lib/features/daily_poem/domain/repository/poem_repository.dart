import 'package:daily_stanza/features/daily_poem/domain/model/daily_poem_result.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/poem.dart';

abstract interface class PoemRepository {
  Future<DailyPoemResult> getDailyPoem({
    required DateTime date,
    required String languageCode,
  });

  Future<List<Poem>> getPoemsByIds(List<String> poemIds);
}
