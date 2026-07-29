import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/poem.dart';
import 'package:daily_stanza/features/daily_poem/domain/repository/poem_repository.dart';
import 'package:daily_stanza/features/poem_details/presentation/cubit/poem_details_cubit.dart';
import 'package:daily_stanza/features/poem_details/presentation/cubit/poem_details_state.dart';

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
  late PoemDetailsCubit cubit;

  setUp(() {
    mockRepository = MockPoemRepository();
    cubit = PoemDetailsCubit(repository: mockRepository);
  });

  tearDown(() {
    cubit.close();
  });

  group('PoemDetailsCubit', () {
    test('initial state is PoemDetailsInitial', () {
      expect(cubit.state, isA<PoemDetailsInitial>());
    });

    blocTest<PoemDetailsCubit, PoemDetailsState>(
      'blank ID emits missing without repository call',
      build: () => PoemDetailsCubit(repository: mockRepository),
      act: (cubit) => cubit.loadPoem(''),
      expect: () => [isA<PoemDetailsMissing>()],
      verify: (_) {
        verifyNever(() => mockRepository.getPoemsByIds(any()));
      },
    );

    blocTest<PoemDetailsCubit, PoemDetailsState>(
      'blank whitespace-only ID emits missing without repository call',
      build: () => PoemDetailsCubit(repository: mockRepository),
      act: (cubit) => cubit.loadPoem('   '),
      expect: () => [isA<PoemDetailsMissing>()],
      verify: (_) {
        verifyNever(() => mockRepository.getPoemsByIds(any()));
      },
    );

    blocTest<PoemDetailsCubit, PoemDetailsState>(
      'valid ID emits loading then loaded',
      build: () {
        when(
          () => mockRepository.getPoemsByIds(any()),
        ).thenAnswer((_) async => const [_testPoem]);
        return PoemDetailsCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.loadPoem('poem1'),
      expect: () => [
        isA<PoemDetailsLoading>(),
        isA<PoemDetailsLoaded>()
            .having((s) => s.poem.id, 'poem.id', 'poem1')
            .having((s) => s.poem.title, 'poem.title', 'The Tyger'),
      ],
    );

    blocTest<PoemDetailsCubit, PoemDetailsState>(
      'repository receives exactly [poemId]',
      build: () {
        when(
          () => mockRepository.getPoemsByIds(any()),
        ).thenAnswer((_) async => const [_testPoem]);
        return PoemDetailsCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.loadPoem('poem1'),
      verify: (_) {
        verify(() => mockRepository.getPoemsByIds(['poem1'])).called(1);
      },
    );

    blocTest<PoemDetailsCubit, PoemDetailsState>(
      'empty repository result emits missing',
      build: () {
        when(
          () => mockRepository.getPoemsByIds(any()),
        ).thenAnswer((_) async => []);
        return PoemDetailsCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.loadPoem('poem1'),
      expect: () => [isA<PoemDetailsLoading>(), isA<PoemDetailsMissing>()],
    );

    blocTest<PoemDetailsCubit, PoemDetailsState>(
      'non-matching result emits missing',
      build: () {
        when(
          () => mockRepository.getPoemsByIds(any()),
        ).thenAnswer((_) async => const [_testPoem]);
        return PoemDetailsCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.loadPoem('wrong-id'),
      expect: () => [isA<PoemDetailsLoading>(), isA<PoemDetailsMissing>()],
    );

    blocTest<PoemDetailsCubit, PoemDetailsState>(
      'repository exception emits failure',
      build: () {
        when(
          () => mockRepository.getPoemsByIds(any()),
        ).thenThrow(Exception('network error'));
        return PoemDetailsCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.loadPoem('poem1'),
      expect: () => [isA<PoemDetailsLoading>(), isA<PoemDetailsFailure>()],
    );

    blocTest<PoemDetailsCubit, PoemDetailsState>(
      'retry reuses the previous ID',
      build: () {
        when(
          () => mockRepository.getPoemsByIds(any()),
        ).thenAnswer((_) async => const [_testPoem]);
        return PoemDetailsCubit(repository: mockRepository);
      },
      act: (cubit) async {
        await cubit.loadPoem('poem1');
        await cubit.retry();
      },
      expect: () => [
        isA<PoemDetailsLoading>(),
        isA<PoemDetailsLoaded>(),
        isA<PoemDetailsLoading>(),
        isA<PoemDetailsLoaded>(),
      ],
      verify: (_) {
        verify(() => mockRepository.getPoemsByIds(['poem1'])).called(2);
      },
    );

    blocTest<PoemDetailsCubit, PoemDetailsState>(
      'retry before first load is a safe no-op',
      build: () => PoemDetailsCubit(repository: mockRepository),
      act: (cubit) async {
        await cubit.retry();
      },
      expect: () => <PoemDetailsState>[],
      verify: (_) {
        verifyNever(() => mockRepository.getPoemsByIds(any()));
      },
    );

    blocTest<PoemDetailsCubit, PoemDetailsState>(
      'repeated load does not accidentally use an older ID',
      build: () {
        when(
          () => mockRepository.getPoemsByIds(any()),
        ).thenAnswer((_) async => const [_testPoem]);
        return PoemDetailsCubit(repository: mockRepository);
      },
      act: (cubit) {
        cubit.loadPoem('poem1');
        cubit.loadPoem('poem2');
      },
      verify: (_) {
        verify(() => mockRepository.getPoemsByIds(['poem1'])).called(1);
        verify(() => mockRepository.getPoemsByIds(['poem2'])).called(1);
      },
    );
  });
}
