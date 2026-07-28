import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daily_stanza/features/daily_poem/data/datasource/firestore_poem_data_source.dart';
import 'package:daily_stanza/features/daily_poem/data/dto/poem_dto.dart';
import 'package:daily_stanza/features/daily_poem/data/exception/poem_data_exception.dart';
import 'package:daily_stanza/features/daily_poem/data/repository/poem_repository_impl.dart';
import 'package:daily_stanza/features/daily_poem/domain/failure/daily_poem_failure.dart';

/// A data source that throws controlled exceptions for failure mapping tests.
class _ThrowingDataSource extends FirestorePoemDataSource {
  _ThrowingDataSource({required this.throwFn})
    : super(firestore: FakeFirebaseFirestore());

  final Object Function() throwFn;

  @override
  Future<(PoemDto, bool)> loadDailyPoem({
    required DateTime date,
    required String languageCode,
  }) async {
    throw throwFn();
  }

  @override
  Future<List<PoemDto>> loadPoemsByIds(List<String> poemIds) async {
    throw throwFn();
  }
}

void main() {
  group('PoemRepositoryImpl failure mapping — getDailyPoem', () {
    PoemRepositoryImpl makeRepo(Object Function() throwFn) {
      return PoemRepositoryImpl(
        dataSource: _ThrowingDataSource(throwFn: throwFn),
      );
    }

    test('DailyPoemNotFoundException → DailyPoemNotFoundFailure', () {
      final repo = makeRepo(() => const DailyPoemNotFoundException());
      expect(
        () =>
            repo.getDailyPoem(date: DateTime(2026, 7, 28), languageCode: 'en'),
        throwsA(isA<DailyPoemNotFoundFailure>()),
      );
    });

    test('PoemNotFoundException → PoemNotFoundFailure', () {
      final repo = makeRepo(() => const PoemNotFoundException());
      expect(
        () =>
            repo.getDailyPoem(date: DateTime(2026, 7, 28), languageCode: 'en'),
        throwsA(isA<PoemNotFoundFailure>()),
      );
    });

    test('AssignmentNotPublishedException → DailyPoemNotFoundFailure', () {
      final repo = makeRepo(() => const AssignmentNotPublishedException());
      expect(
        () =>
            repo.getDailyPoem(date: DateTime(2026, 7, 28), languageCode: 'en'),
        throwsA(
          isA<DailyPoemNotFoundFailure>().having(
            (f) => f.message,
            'message',
            'Assignment is not published.',
          ),
        ),
      );
    });

    test('PoemNotApprovedException → InvalidPoemDataFailure', () {
      final repo = makeRepo(() => const PoemNotApprovedException());
      expect(
        () =>
            repo.getDailyPoem(date: DateTime(2026, 7, 28), languageCode: 'en'),
        throwsA(
          isA<InvalidPoemDataFailure>().having(
            (f) => f.message,
            'message',
            'Poem is not approved.',
          ),
        ),
      );
    });

    test('FormatException → InvalidPoemDataFailure', () {
      final repo = makeRepo(() => const FormatException('bad json'));
      expect(
        () =>
            repo.getDailyPoem(date: DateTime(2026, 7, 28), languageCode: 'en'),
        throwsA(
          isA<InvalidPoemDataFailure>().having(
            (f) => f.message,
            'message',
            'bad json',
          ),
        ),
      );
    });

    test('permission-denied → PermissionFailure', () {
      final repo = makeRepo(() => Exception('RpcError: permission-denied'));
      expect(
        () =>
            repo.getDailyPoem(date: DateTime(2026, 7, 28), languageCode: 'en'),
        throwsA(isA<PermissionFailure>()),
      );
    });

    test('unavailable → NetworkFailure', () {
      final repo = makeRepo(() => Exception('UNAVAILABLE: server unavailable'));
      expect(
        () =>
            repo.getDailyPoem(date: DateTime(2026, 7, 28), languageCode: 'en'),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('deadline-exceeded → NetworkFailure', () {
      final repo = makeRepo(() => Exception('deadline-exceeded'));
      expect(
        () =>
            repo.getDailyPoem(date: DateTime(2026, 7, 28), languageCode: 'en'),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('generic exception → UnknownFailure', () {
      final repo = makeRepo(() => Exception('totally unknown'));
      expect(
        () =>
            repo.getDailyPoem(date: DateTime(2026, 7, 28), languageCode: 'en'),
        throwsA(isA<UnknownFailure>()),
      );
    });

    test('rethrows DailyPoemFailure subclasses directly', () {
      final repo = makeRepo(() => const NetworkFailure('custom'));
      expect(
        () =>
            repo.getDailyPoem(date: DateTime(2026, 7, 28), languageCode: 'en'),
        throwsA(
          isA<NetworkFailure>().having((f) => f.message, 'message', 'custom'),
        ),
      );
    });
  });

  group('PoemRepositoryImpl failure mapping — getPoemsByIds', () {
    PoemRepositoryImpl makeRepo(Object Function() throwFn) {
      return PoemRepositoryImpl(
        dataSource: _ThrowingDataSource(throwFn: throwFn),
      );
    }

    test('FormatException → InvalidPoemDataFailure', () {
      final repo = makeRepo(() => const FormatException('invalid poem data'));
      expect(
        () => repo.getPoemsByIds(['poem1']),
        throwsA(
          isA<InvalidPoemDataFailure>().having(
            (f) => f.message,
            'message',
            'invalid poem data',
          ),
        ),
      );
    });

    test('permission error → PermissionFailure', () {
      final repo = makeRepo(() => Exception('permission-denied'));
      expect(
        () => repo.getPoemsByIds(['poem1']),
        throwsA(isA<PermissionFailure>()),
      );
    });

    test('network error → NetworkFailure', () {
      final repo = makeRepo(() => Exception('network error'));
      expect(
        () => repo.getPoemsByIds(['poem1']),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('unknown error → UnknownFailure', () {
      final repo = makeRepo(() => Exception('something weird'));
      expect(
        () => repo.getPoemsByIds(['poem1']),
        throwsA(isA<UnknownFailure>()),
      );
    });
  });
}
