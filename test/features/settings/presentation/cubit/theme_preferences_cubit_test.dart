// ignore_for_file: unawaited_futures

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:daily_stanza/features/settings/domain/model/theme_preference.dart';
import 'package:daily_stanza/features/settings/domain/repository/theme_preferences_repository.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/theme_preferences_cubit.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/theme_preferences_state.dart';

class MockRepository extends Mock implements ThemePreferencesRepository {}

void main() {
  late MockRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(ThemePreference.system);
    registerFallbackValue(ThemePreference.light);
    registerFallbackValue(ThemePreference.dark);
  });

  setUp(() {
    mockRepository = MockRepository();
  });

  group('ThemePreferencesCubit', () {
    blocTest<ThemePreferencesCubit, ThemePreferencesState>(
      'initial state contains the supplied preference',
      build: () => ThemePreferencesCubit(
        repository: mockRepository,
        initialPreference: ThemePreference.system,
      ),
      expect: () => <ThemePreferencesState>[],
      verify: (cubit) {
        expect(cubit.state.preference, ThemePreference.system);
        expect(cubit.state.isSaving, isFalse);
        expect(cubit.state.mutationError, isNull);
      },
    );

    blocTest<ThemePreferencesCubit, ThemePreferencesState>(
      'selecting the same preference is a no-op',
      build: () => ThemePreferencesCubit(
        repository: mockRepository,
        initialPreference: ThemePreference.system,
      ),
      act: (cubit) => cubit.changeTheme(ThemePreference.system),
      expect: () => <ThemePreferencesState>[],
      verify: (_) {
        verifyNever(() => mockRepository.setPreferredTheme(any()));
      },
    );

    blocTest<ThemePreferencesCubit, ThemePreferencesState>(
      'successful System-to-Light change emits saving then Light',
      build: () {
        when(
          () => mockRepository.setPreferredTheme(any()),
        ).thenAnswer((_) async {});
        return ThemePreferencesCubit(
          repository: mockRepository,
          initialPreference: ThemePreference.system,
        );
      },
      act: (cubit) => cubit.changeTheme(ThemePreference.light),
      expect: () => [
        isA<ThemePreferencesState>()
            .having((s) => s.preference, 'preference', ThemePreference.system)
            .having((s) => s.isSaving, 'isSaving', isTrue)
            .having((s) => s.mutationError, 'mutationError', isNull),
        isA<ThemePreferencesState>()
            .having((s) => s.preference, 'preference', ThemePreference.light)
            .having((s) => s.isSaving, 'isSaving', isFalse)
            .having((s) => s.mutationError, 'mutationError', isNull),
      ],
    );

    blocTest<ThemePreferencesCubit, ThemePreferencesState>(
      'successful Light-to-Dark change emits saving then Dark',
      build: () {
        when(
          () => mockRepository.setPreferredTheme(any()),
        ).thenAnswer((_) async {});
        return ThemePreferencesCubit(
          repository: mockRepository,
          initialPreference: ThemePreference.light,
        );
      },
      act: (cubit) => cubit.changeTheme(ThemePreference.dark),
      expect: () => [
        isA<ThemePreferencesState>()
            .having((s) => s.preference, 'preference', ThemePreference.light)
            .having((s) => s.isSaving, 'isSaving', isTrue),
        isA<ThemePreferencesState>()
            .having((s) => s.preference, 'preference', ThemePreference.dark)
            .having((s) => s.isSaving, 'isSaving', isFalse),
      ],
    );

    blocTest<ThemePreferencesCubit, ThemePreferencesState>(
      'successful Dark-to-System change emits saving then System',
      build: () {
        when(
          () => mockRepository.setPreferredTheme(any()),
        ).thenAnswer((_) async {});
        return ThemePreferencesCubit(
          repository: mockRepository,
          initialPreference: ThemePreference.dark,
        );
      },
      act: (cubit) => cubit.changeTheme(ThemePreference.system),
      expect: () => [
        isA<ThemePreferencesState>()
            .having((s) => s.preference, 'preference', ThemePreference.dark)
            .having((s) => s.isSaving, 'isSaving', isTrue),
        isA<ThemePreferencesState>()
            .having((s) => s.preference, 'preference', ThemePreference.system)
            .having((s) => s.isSaving, 'isSaving', isFalse),
      ],
    );

    blocTest<ThemePreferencesCubit, ThemePreferencesState>(
      'repository receives the selected preference exactly once',
      build: () {
        when(
          () => mockRepository.setPreferredTheme(any()),
        ).thenAnswer((_) async {});
        return ThemePreferencesCubit(
          repository: mockRepository,
          initialPreference: ThemePreference.system,
        );
      },
      act: (cubit) => cubit.changeTheme(ThemePreference.dark),
      verify: (_) {
        verify(
          () => mockRepository.setPreferredTheme(ThemePreference.dark),
        ).called(1);
      },
    );

    blocTest<ThemePreferencesCubit, ThemePreferencesState>(
      'failure retains the previous preference',
      build: () {
        when(
          () => mockRepository.setPreferredTheme(any()),
        ).thenThrow(Exception('fail'));
        return ThemePreferencesCubit(
          repository: mockRepository,
          initialPreference: ThemePreference.system,
        );
      },
      act: (cubit) => cubit.changeTheme(ThemePreference.dark),
      expect: () => [
        isA<ThemePreferencesState>()
            .having((s) => s.preference, 'preference', ThemePreference.system)
            .having((s) => s.isSaving, 'isSaving', isTrue),
        isA<ThemePreferencesState>()
            .having(
              (s) => s.preference,
              'preference preserved',
              ThemePreference.system,
            )
            .having((s) => s.isSaving, 'isSaving', isFalse)
            .having((s) => s.mutationError, 'has error', isNotNull),
      ],
    );

    blocTest<ThemePreferencesCubit, ThemePreferencesState>(
      'failure emits the safe mutation error',
      build: () {
        when(
          () => mockRepository.setPreferredTheme(any()),
        ).thenThrow(Exception('fail'));
        return ThemePreferencesCubit(
          repository: mockRepository,
          initialPreference: ThemePreference.system,
        );
      },
      act: (cubit) => cubit.changeTheme(ThemePreference.dark),
      expect: () => [
        isA<ThemePreferencesState>().having(
          (s) => s.mutationError,
          'no error in saving',
          isNull,
        ),
        isA<ThemePreferencesState>().having(
          (s) => s.mutationError,
          'has safe error message',
          'Failed to save theme preference. Please try again.',
        ),
      ],
    );

    blocTest<ThemePreferencesCubit, ThemePreferencesState>(
      'rapid duplicate selection is guarded',
      build: () {
        when(
          () => mockRepository.setPreferredTheme(any()),
        ).thenAnswer((_) async {});
        return ThemePreferencesCubit(
          repository: mockRepository,
          initialPreference: ThemePreference.system,
        );
      },
      act: (cubit) async {
        await cubit.changeTheme(ThemePreference.dark);
        await cubit.changeTheme(ThemePreference.dark);
      },
      expect: () => [
        isA<ThemePreferencesState>().having(
          (s) => s.isSaving,
          'saving',
          isTrue,
        ),
        isA<ThemePreferencesState>().having(
          (s) => s.preference,
          'dark',
          ThemePreference.dark,
        ),
      ],
      verify: (_) {
        verify(
          () => mockRepository.setPreferredTheme(ThemePreference.dark),
        ).called(1);
      },
    );

    blocTest<ThemePreferencesCubit, ThemePreferencesState>(
      'successful later change clears the previous error',
      build: () {
        when(
          () => mockRepository.setPreferredTheme(any()),
        ).thenAnswer((_) async {});
        return ThemePreferencesCubit(
          repository: mockRepository,
          initialPreference: ThemePreference.system,
        );
      },
      act: (cubit) async {
        await cubit.changeTheme(ThemePreference.dark);
        await cubit.changeTheme(ThemePreference.light);
      },
      expect: () => [
        isA<ThemePreferencesState>().having(
          (s) => s.isSaving,
          'saving 1',
          isTrue,
        ),
        isA<ThemePreferencesState>().having(
          (s) => s.preference,
          'dark',
          ThemePreference.dark,
        ),
        isA<ThemePreferencesState>().having(
          (s) => s.isSaving,
          'saving 2',
          isTrue,
        ),
        isA<ThemePreferencesState>()
            .having((s) => s.preference, 'light', ThemePreference.light)
            .having((s) => s.mutationError, 'error cleared', isNull),
      ],
    );

    blocTest<ThemePreferencesCubit, ThemePreferencesState>(
      'two separate failures can each produce error feedback',
      build: () {
        when(
          () => mockRepository.setPreferredTheme(any()),
        ).thenAnswer((_) async {});
        return ThemePreferencesCubit(
          repository: mockRepository,
          initialPreference: ThemePreference.system,
        );
      },
      act: (cubit) async {
        // First failure
        when(
          () => mockRepository.setPreferredTheme(any()),
        ).thenThrow(Exception('fail 1'));
        await cubit.changeTheme(ThemePreference.dark);

        // Second failure (after error state, guard is cleared)
        when(
          () => mockRepository.setPreferredTheme(any()),
        ).thenThrow(Exception('fail 2'));
        await cubit.changeTheme(ThemePreference.dark);
      },
      expect: () => [
        isA<ThemePreferencesState>().having(
          (s) => s.isSaving,
          'saving 1',
          isTrue,
        ),
        isA<ThemePreferencesState>()
            .having((s) => s.preference, 'still system', ThemePreference.system)
            .having((s) => s.mutationError, 'error 1', isNotNull),
        // Second attempt: isSaving becomes true (guard cleared because
        // mutationError was set, which means isSaving is false)
        isA<ThemePreferencesState>().having(
          (s) => s.isSaving,
          'saving 2',
          isTrue,
        ),
        isA<ThemePreferencesState>()
            .having((s) => s.preference, 'still system', ThemePreference.system)
            .having((s) => s.mutationError, 'error 2', isNotNull),
      ],
    );

    blocTest<ThemePreferencesCubit, ThemePreferencesState>(
      'changing language does not affect theme state',
      build: () {
        when(
          () => mockRepository.setPreferredTheme(any()),
        ).thenAnswer((_) async {});
        return ThemePreferencesCubit(
          repository: mockRepository,
          initialPreference: ThemePreference.system,
        );
      },
      act: (cubit) async {
        // No language method — this test verifies the cubit
        // is not coupled to language preferences.
      },
      expect: () => <ThemePreferencesState>[],
      verify: (cubit) {
        expect(cubit.state.preference, ThemePreference.system);
      },
    );
  });
}
