import 'package:daily_stanza/features/daily_poem/data/datasource/firestore_poem_data_source.dart';
import 'package:daily_stanza/features/daily_poem/data/exception/poem_data_exception.dart';
import 'package:daily_stanza/features/daily_poem/domain/failure/daily_poem_failure.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/daily_poem_result.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/poem.dart';
import 'package:daily_stanza/features/daily_poem/domain/repository/poem_repository.dart';

class PoemRepositoryImpl implements PoemRepository {
  const PoemRepositoryImpl({required FirestorePoemDataSource dataSource})
    : _dataSource = dataSource;

  final FirestorePoemDataSource _dataSource;

  @override
  Future<DailyPoemResult> getDailyPoem({
    required DateTime date,
    required String languageCode,
  }) async {
    try {
      final (poemDto, isFromCache) = await _dataSource.loadDailyPoem(
        date: date,
        languageCode: languageCode,
      );
      return DailyPoemResult(
        poem: poemDto.toDomain(),
        isFromCache: isFromCache,
      );
    } on DailyPoemNotFoundException {
      throw const DailyPoemNotFoundFailure();
    } on AssignmentNotPublishedException {
      throw const DailyPoemNotFoundFailure('Assignment is not published.');
    } on PoemNotFoundException {
      throw const PoemNotFoundFailure();
    } on PoemNotApprovedException {
      throw const InvalidPoemDataFailure('Poem is not approved.');
    } on FormatException catch (e) {
      throw InvalidPoemDataFailure(e.message);
    } on DataPermissionException {
      throw const PermissionFailure();
    } on DataUnavailableException {
      throw const NetworkFailure();
    } on FirebaseDataException {
      throw const UnknownFailure();
    } on DailyPoemFailure {
      rethrow;
    } catch (e) {
      throw const UnknownFailure();
    }
  }

  @override
  Future<List<Poem>> getPoemsByIds(List<String> poemIds) async {
    try {
      final dtos = await _dataSource.loadPoemsByIds(poemIds);
      return dtos.map((dto) => dto.toDomain()).toList();
    } on FormatException catch (e) {
      throw InvalidPoemDataFailure(e.message);
    } on DataPermissionException {
      throw const PermissionFailure();
    } on DataUnavailableException {
      throw const NetworkFailure();
    } on FirebaseDataException {
      throw const UnknownFailure();
    } on DailyPoemFailure {
      rethrow;
    } catch (e) {
      throw const UnknownFailure();
    }
  }
}
