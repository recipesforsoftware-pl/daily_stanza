import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:daily_stanza/features/settings/domain/model/poem_language.dart';
import 'package:daily_stanza/features/settings/domain/repository/language_preferences_repository.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/language_preferences_cubit.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/language_preferences_state.dart';

class MockRepository extends Mock implements LanguagePreferencesRepository {}

void main() {
  late MockRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(PoemLanguage.english);
    registerFallbackValue(PoemLanguage.polish);
  });

  setUp(() {
    mockRepository = MockRepository();
  });

  group('LanguagePreferencesCubit', () {
    blocTest<LanguagePreferencesCubit, LanguagePreferencesState>(
      'initial state contains the supplied initial language',
      build: () => LanguagePreferencesCubit(
        repository: mockRepository,
        initialLanguage: PoemLanguage.english,
      ),
      expect: () => <LanguagePreferencesState>[],
      verify: (cubit) {
        expect(cubit.state.language, PoemLanguage.english);
        expect(cubit.state.isSaving, isFalse);
        expect(cubit.state.mutationError, isNull);
      },
    );

    blocTest<LanguagePreferencesCubit, LanguagePreferencesState>(
      'selecting the same language is a no-op',
      build: () => LanguagePreferencesCubit(
        repository: mockRepository,
        initialLanguage: PoemLanguage.english,
      ),
      act: (cubit) => cubit.changeLanguage(PoemLanguage.english),
      expect: () => <LanguagePreferencesState>[],
      verify: (_) {
        verifyNever(() => mockRepository.setPreferredLanguage(any()));
      },
    );

    blocTest<LanguagePreferencesCubit, LanguagePreferencesState>(
      'successful English-to-Polish change emits saving then Polish',
      build: () {
        when(
          () => mockRepository.setPreferredLanguage(any()),
        ).thenAnswer((_) async {});
        return LanguagePreferencesCubit(
          repository: mockRepository,
          initialLanguage: PoemLanguage.english,
        );
      },
      act: (cubit) => cubit.changeLanguage(PoemLanguage.polish),
      expect: () => [
        isA<LanguagePreferencesState>()
            .having((s) => s.language, 'language', PoemLanguage.english)
            .having((s) => s.isSaving, 'isSaving', isTrue)
            .having((s) => s.mutationError, 'mutationError', isNull),
        isA<LanguagePreferencesState>()
            .having((s) => s.language, 'language', PoemLanguage.polish)
            .having((s) => s.isSaving, 'isSaving', isFalse)
            .having((s) => s.mutationError, 'mutationError', isNull),
      ],
    );

    blocTest<LanguagePreferencesCubit, LanguagePreferencesState>(
      'successful Polish-to-English change emits saving then English',
      build: () {
        when(
          () => mockRepository.setPreferredLanguage(any()),
        ).thenAnswer((_) async {});
        return LanguagePreferencesCubit(
          repository: mockRepository,
          initialLanguage: PoemLanguage.polish,
        );
      },
      act: (cubit) => cubit.changeLanguage(PoemLanguage.english),
      expect: () => [
        isA<LanguagePreferencesState>()
            .having((s) => s.language, 'language', PoemLanguage.polish)
            .having((s) => s.isSaving, 'isSaving', isTrue),
        isA<LanguagePreferencesState>()
            .having((s) => s.language, 'language', PoemLanguage.english)
            .having((s) => s.isSaving, 'isSaving', isFalse),
      ],
    );

    blocTest<LanguagePreferencesCubit, LanguagePreferencesState>(
      'repository receives the selected language exactly once',
      build: () {
        when(
          () => mockRepository.setPreferredLanguage(any()),
        ).thenAnswer((_) async {});
        return LanguagePreferencesCubit(
          repository: mockRepository,
          initialLanguage: PoemLanguage.english,
        );
      },
      act: (cubit) => cubit.changeLanguage(PoemLanguage.polish),
      verify: (_) {
        verify(
          () => mockRepository.setPreferredLanguage(PoemLanguage.polish),
        ).called(1);
      },
    );

    blocTest<LanguagePreferencesCubit, LanguagePreferencesState>(
      'failure retains the previous language',
      build: () {
        when(
          () => mockRepository.setPreferredLanguage(any()),
        ).thenThrow(Exception('fail'));
        return LanguagePreferencesCubit(
          repository: mockRepository,
          initialLanguage: PoemLanguage.english,
        );
      },
      act: (cubit) => cubit.changeLanguage(PoemLanguage.polish),
      expect: () => [
        isA<LanguagePreferencesState>()
            .having((s) => s.language, 'language', PoemLanguage.english)
            .having((s) => s.isSaving, 'isSaving', isTrue),
        isA<LanguagePreferencesState>()
            .having(
              (s) => s.language,
              'language preserved',
              PoemLanguage.english,
            )
            .having((s) => s.isSaving, 'isSaving', isFalse)
            .having((s) => s.mutationError, 'has error', isNotNull),
      ],
    );

    blocTest<LanguagePreferencesCubit, LanguagePreferencesState>(
      'failure emits the safe mutation error',
      build: () {
        when(
          () => mockRepository.setPreferredLanguage(any()),
        ).thenThrow(Exception('fail'));
        return LanguagePreferencesCubit(
          repository: mockRepository,
          initialLanguage: PoemLanguage.english,
        );
      },
      act: (cubit) => cubit.changeLanguage(PoemLanguage.polish),
      expect: () => [
        isA<LanguagePreferencesState>().having(
          (s) => s.mutationError,
          'no error in saving',
          isNull,
        ),
        isA<LanguagePreferencesState>().having(
          (s) => s.mutationError,
          'has safe error message',
          'Failed to save language preference. Please try again.',
        ),
      ],
    );

    blocTest<LanguagePreferencesCubit, LanguagePreferencesState>(
      'rapid duplicate selection is guarded',
      build: () {
        when(
          () => mockRepository.setPreferredLanguage(any()),
        ).thenAnswer((_) async {});
        return LanguagePreferencesCubit(
          repository: mockRepository,
          initialLanguage: PoemLanguage.english,
        );
      },
      act: (cubit) async {
        await cubit.changeLanguage(PoemLanguage.polish);
        await cubit.changeLanguage(PoemLanguage.polish);
      },
      expect: () => [
        isA<LanguagePreferencesState>().having(
          (s) => s.isSaving,
          'saving',
          isTrue,
        ),
        isA<LanguagePreferencesState>().having(
          (s) => s.language,
          'polish',
          PoemLanguage.polish,
        ),
      ],
      verify: (_) {
        verify(
          () => mockRepository.setPreferredLanguage(PoemLanguage.polish),
        ).called(1);
      },
    );

    blocTest<LanguagePreferencesCubit, LanguagePreferencesState>(
      'successful later change clears the previous error',
      build: () {
        when(
          () => mockRepository.setPreferredLanguage(any()),
        ).thenAnswer((_) async {});
        return LanguagePreferencesCubit(
          repository: mockRepository,
          initialLanguage: PoemLanguage.english,
        );
      },
      act: (cubit) async {
        await cubit.changeLanguage(PoemLanguage.polish);
        await cubit.changeLanguage(PoemLanguage.english);
      },
      expect: () => [
        isA<LanguagePreferencesState>().having(
          (s) => s.isSaving,
          'saving 1',
          isTrue,
        ),
        isA<LanguagePreferencesState>().having(
          (s) => s.language,
          'polish',
          PoemLanguage.polish,
        ),
        isA<LanguagePreferencesState>().having(
          (s) => s.isSaving,
          'saving 2',
          isTrue,
        ),
        isA<LanguagePreferencesState>()
            .having((s) => s.language, 'english', PoemLanguage.english)
            .having((s) => s.mutationError, 'error cleared', isNull),
      ],
    );

    blocTest<LanguagePreferencesCubit, LanguagePreferencesState>(
      'two separate failures can each produce error feedback',
      build: () {
        when(
          () => mockRepository.setPreferredLanguage(any()),
        ).thenAnswer((_) async {});
        return LanguagePreferencesCubit(
          repository: mockRepository,
          initialLanguage: PoemLanguage.english,
        );
      },
      act: (cubit) async {
        // First failure
        when(
          () => mockRepository.setPreferredLanguage(any()),
        ).thenThrow(Exception('fail 1'));
        await cubit.changeLanguage(PoemLanguage.polish);

        // Second failure (after error state, guard is cleared)
        when(
          () => mockRepository.setPreferredLanguage(any()),
        ).thenThrow(Exception('fail 2'));
        await cubit.changeLanguage(PoemLanguage.polish);
      },
      expect: () => [
        isA<LanguagePreferencesState>().having(
          (s) => s.isSaving,
          'saving 1',
          isTrue,
        ),
        isA<LanguagePreferencesState>()
            .having((s) => s.language, 'still english', PoemLanguage.english)
            .having((s) => s.mutationError, 'error 1', isNotNull),
        // Second attempt: isSaving becomes true (guard cleared because
        // mutationError was set, which means isSaving is false)
        isA<LanguagePreferencesState>().having(
          (s) => s.isSaving,
          'saving 2',
          isTrue,
        ),
        isA<LanguagePreferencesState>()
            .having((s) => s.language, 'still english', PoemLanguage.english)
            .having((s) => s.mutationError, 'error 2', isNotNull),
      ],
    );
  });
}
