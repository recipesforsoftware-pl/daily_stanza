import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:daily_stanza/features/daily_poem/domain/failure/daily_poem_failure.dart'
    as domain;
import 'package:daily_stanza/features/daily_poem/domain/model/daily_poem_result.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/poem.dart';
import 'package:daily_stanza/features/daily_poem/domain/repository/poem_repository.dart';
import 'package:daily_stanza/features/daily_poem/presentation/bloc/daily_poem_bloc.dart';
import 'package:daily_stanza/features/daily_poem/presentation/bloc/daily_poem_event.dart';
import 'package:daily_stanza/features/daily_poem/presentation/bloc/daily_poem_state.dart';

class MockPoemRepository extends Mock implements PoemRepository {}

const _testPoem = Poem(
  id: 'poem1',
  title: 'The Tyger',
  author: 'William Blake',
  languageCode: 'en',
  countryCode: 'GB',
  content: 'Tyger Tyger, burning bright,\nIn the forests of the night;',
  sourceName: 'Songs of Experience',
  sourceUrl: 'https://en.wikisource.org/wiki/The_Tyger',
  rightsStatus: 'public_domain',
);

void main() {
  late MockPoemRepository mockRepository;
  late DailyPoemBloc bloc;

  setUp(() {
    mockRepository = MockPoemRepository();
    bloc = DailyPoemBloc(repository: mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  setUpAll(() {
    registerFallbackValue(DateTime(2026, 7, 28));
  });

  group('DailyPoemBloc', () {
    test('initial state is DailyPoemInitial', () {
      expect(bloc.state, isA<DailyPoemInitial>());
    });

    blocTest<DailyPoemBloc, DailyPoemState>(
      'emits loading then loaded on DailyPoemRequested',
      build: () {
        when(
          () => mockRepository.getDailyPoem(
            date: any(named: 'date'),
            languageCode: any(named: 'languageCode'),
          ),
        ).thenAnswer(
          (_) async =>
              const DailyPoemResult(poem: _testPoem, isFromCache: false),
        );
        return DailyPoemBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(
        DailyPoemRequested(date: DateTime(2026, 7, 28), languageCode: 'en'),
      ),
      expect: () => [
        isA<DailyPoemLoading>(),
        isA<DailyPoemLoaded>()
            .having((s) => s.poem.id, 'poem.id', 'poem1')
            .having((s) => s.isFromCache, 'isFromCache', false),
      ],
    );

    blocTest<DailyPoemBloc, DailyPoemState>(
      'loaded state preserves isFromCache = true',
      build: () {
        when(
          () => mockRepository.getDailyPoem(
            date: any(named: 'date'),
            languageCode: any(named: 'languageCode'),
          ),
        ).thenAnswer(
          (_) async =>
              const DailyPoemResult(poem: _testPoem, isFromCache: true),
        );
        return DailyPoemBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(
        DailyPoemRequested(date: DateTime(2026, 7, 28), languageCode: 'en'),
      ),
      expect: () => [
        isA<DailyPoemLoading>(),
        isA<DailyPoemLoaded>().having(
          (s) => s.isFromCache,
          'isFromCache',
          true,
        ),
      ],
    );

    blocTest<DailyPoemBloc, DailyPoemState>(
      'missing daily assignment emits DailyPoemMissing',
      build: () {
        when(
          () => mockRepository.getDailyPoem(
            date: any(named: 'date'),
            languageCode: any(named: 'languageCode'),
          ),
        ).thenThrow(const domain.DailyPoemNotFoundFailure());
        return DailyPoemBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(
        DailyPoemRequested(date: DateTime(2026, 7, 28), languageCode: 'en'),
      ),
      expect: () => [isA<DailyPoemLoading>(), isA<DailyPoemMissing>()],
    );

    blocTest<DailyPoemBloc, DailyPoemState>(
      'missing referenced poem emits DailyPoemMissing',
      build: () {
        when(
          () => mockRepository.getDailyPoem(
            date: any(named: 'date'),
            languageCode: any(named: 'languageCode'),
          ),
        ).thenThrow(const domain.PoemNotFoundFailure());
        return DailyPoemBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(
        DailyPoemRequested(date: DateTime(2026, 7, 28), languageCode: 'en'),
      ),
      expect: () => [isA<DailyPoemLoading>(), isA<DailyPoemMissing>()],
    );

    blocTest<DailyPoemBloc, DailyPoemState>(
      'network failure maps to network presentation failure',
      build: () {
        when(
          () => mockRepository.getDailyPoem(
            date: any(named: 'date'),
            languageCode: any(named: 'languageCode'),
          ),
        ).thenThrow(const domain.NetworkFailure());
        return DailyPoemBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(
        DailyPoemRequested(date: DateTime(2026, 7, 28), languageCode: 'en'),
      ),
      expect: () => [
        isA<DailyPoemLoading>(),
        isA<DailyPoemFailure>().having(
          (s) => s.failureType,
          'failureType',
          DailyPoemFailureType.network,
        ),
      ],
    );

    blocTest<DailyPoemBloc, DailyPoemState>(
      'permission failure maps to permission presentation failure',
      build: () {
        when(
          () => mockRepository.getDailyPoem(
            date: any(named: 'date'),
            languageCode: any(named: 'languageCode'),
          ),
        ).thenThrow(const domain.PermissionFailure());
        return DailyPoemBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(
        DailyPoemRequested(date: DateTime(2026, 7, 28), languageCode: 'en'),
      ),
      expect: () => [
        isA<DailyPoemLoading>(),
        isA<DailyPoemFailure>().having(
          (s) => s.failureType,
          'failureType',
          DailyPoemFailureType.permission,
        ),
      ],
    );

    blocTest<DailyPoemBloc, DailyPoemState>(
      'invalid data failure maps to unknown presentation failure',
      build: () {
        when(
          () => mockRepository.getDailyPoem(
            date: any(named: 'date'),
            languageCode: any(named: 'languageCode'),
          ),
        ).thenThrow(const domain.InvalidPoemDataFailure());
        return DailyPoemBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(
        DailyPoemRequested(date: DateTime(2026, 7, 28), languageCode: 'en'),
      ),
      expect: () => [
        isA<DailyPoemLoading>(),
        isA<DailyPoemFailure>().having(
          (s) => s.failureType,
          'failureType',
          DailyPoemFailureType.unknown,
        ),
      ],
    );

    blocTest<DailyPoemBloc, DailyPoemState>(
      'unknown failure maps to unknown presentation failure',
      build: () {
        when(
          () => mockRepository.getDailyPoem(
            date: any(named: 'date'),
            languageCode: any(named: 'languageCode'),
          ),
        ).thenThrow(const domain.UnknownFailure());
        return DailyPoemBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(
        DailyPoemRequested(date: DateTime(2026, 7, 28), languageCode: 'en'),
      ),
      expect: () => [
        isA<DailyPoemLoading>(),
        isA<DailyPoemFailure>().having(
          (s) => s.failureType,
          'failureType',
          DailyPoemFailureType.unknown,
        ),
      ],
    );

    blocTest<DailyPoemBloc, DailyPoemState>(
      'retry repeats the last date and language',
      build: () {
        when(
          () => mockRepository.getDailyPoem(
            date: any(named: 'date'),
            languageCode: any(named: 'languageCode'),
          ),
        ).thenAnswer(
          (_) async =>
              const DailyPoemResult(poem: _testPoem, isFromCache: false),
        );
        return DailyPoemBloc(repository: mockRepository);
      },
      act: (bloc) {
        bloc.add(
          DailyPoemRequested(date: DateTime(2026, 7, 28), languageCode: 'en'),
        );
        bloc.add(const DailyPoemRetryRequested());
      },
      expect: () => [
        isA<DailyPoemLoading>(),
        isA<DailyPoemLoaded>(),
        isA<DailyPoemLoading>(),
        isA<DailyPoemLoaded>(),
      ],
      verify: (_) {
        verify(
          () => mockRepository.getDailyPoem(
            date: DateTime(2026, 7, 28),
            languageCode: 'en',
          ),
        ).called(2);
      },
    );

    blocTest<DailyPoemBloc, DailyPoemState>(
      'retry before initial request does not crash',
      build: () => DailyPoemBloc(repository: mockRepository),
      act: (bloc) => bloc.add(const DailyPoemRetryRequested()),
      expect: () => <DailyPoemState>[],
    );
  });
}
