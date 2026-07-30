import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:daily_stanza/features/onboarding/domain/repository/onboarding_repository.dart';
import 'package:daily_stanza/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:daily_stanza/features/onboarding/presentation/cubit/onboarding_state.dart';

class MockRepository extends Mock implements OnboardingRepository {}

void main() {
  late MockRepository mockRepository;

  setUp(() {
    mockRepository = MockRepository();
  });

  group('OnboardingCubit', () {
    blocTest<OnboardingCubit, OnboardingState>(
      'initial state is resolving',
      build: () {
        when(
          () => mockRepository.isOnboardingCompleted(),
        ).thenAnswer((_) async => false);
        return OnboardingCubit(repository: mockRepository);
      },
      expect: () => [
        isA<OnboardingState>()
            .having((s) => s.status, 'status', OnboardingStatus.resolved)
            .having((s) => s.completed, 'completed', isFalse),
      ],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'resolved incomplete state is correct',
      build: () {
        when(
          () => mockRepository.isOnboardingCompleted(),
        ).thenAnswer((_) async => false);
        return OnboardingCubit(repository: mockRepository);
      },
      verify: (cubit) {
        expect(cubit.state.status, OnboardingStatus.resolved);
        expect(cubit.state.completed, isFalse);
        expect(cubit.state.isCompleting, isFalse);
        expect(cubit.state.mutationError, isNull);
      },
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'resolved complete state is correct',
      build: () {
        when(
          () => mockRepository.isOnboardingCompleted(),
        ).thenAnswer((_) async => true);
        return OnboardingCubit(repository: mockRepository);
      },
      verify: (cubit) {
        expect(cubit.state.status, OnboardingStatus.resolved);
        expect(cubit.state.completed, isTrue);
      },
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'read failure is treated as incomplete',
      build: () {
        when(
          () => mockRepository.isOnboardingCompleted(),
        ).thenThrow(Exception('read failed'));
        return OnboardingCubit(repository: mockRepository);
      },
      verify: (cubit) {
        expect(cubit.state.status, OnboardingStatus.resolved);
        expect(cubit.state.completed, isFalse);
      },
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'completeOnboarding persists and emits completed',
      build: () {
        when(
          () => mockRepository.isOnboardingCompleted(),
        ).thenAnswer((_) async => false);
        when(
          () => mockRepository.setOnboardingCompleted(),
        ).thenAnswer((_) async {});
        return OnboardingCubit(repository: mockRepository);
      },
      act: (cubit) async {
        await cubit.stream.firstWhere(
          (s) => s.status == OnboardingStatus.resolved,
        );
        await cubit.completeOnboarding();
      },
      expect: () => [
        isA<OnboardingState>()
            .having((s) => s.status, 'status', OnboardingStatus.resolved)
            .having((s) => s.completed, 'completed', isFalse)
            .having((s) => s.isCompleting, 'isCompleting', isFalse),
        isA<OnboardingState>()
            .having((s) => s.status, 'status', OnboardingStatus.resolved)
            .having((s) => s.isCompleting, 'isCompleting', isTrue)
            .having((s) => s.completed, 'completed', isFalse),
        isA<OnboardingState>()
            .having((s) => s.isCompleting, 'isCompleting', isFalse)
            .having((s) => s.completed, 'completed', isTrue)
            .having((s) => s.status, 'status', OnboardingStatus.resolved),
      ],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'Skip completes onboarding',
      build: () {
        when(
          () => mockRepository.isOnboardingCompleted(),
        ).thenAnswer((_) async => false);
        when(
          () => mockRepository.setOnboardingCompleted(),
        ).thenAnswer((_) async {});
        return OnboardingCubit(repository: mockRepository);
      },
      act: (cubit) async {
        await cubit.stream.firstWhere(
          (s) => s.status == OnboardingStatus.resolved,
        );
        await cubit.completeOnboarding();
      },
      verify: (_) {
        verify(() => mockRepository.setOnboardingCompleted()).called(1);
      },
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'repeated completeOnboarding does not produce duplicate processing',
      build: () {
        when(
          () => mockRepository.isOnboardingCompleted(),
        ).thenAnswer((_) async => false);
        when(
          () => mockRepository.setOnboardingCompleted(),
        ).thenAnswer((_) async {});
        return OnboardingCubit(repository: mockRepository);
      },
      act: (cubit) async {
        await cubit.stream.firstWhere(
          (s) => s.status == OnboardingStatus.resolved,
        );
        await cubit.completeOnboarding();
        await cubit.completeOnboarding();
      },
      expect: () => [
        isA<OnboardingState>()
            .having((s) => s.status, 'status', OnboardingStatus.resolved)
            .having((s) => s.completed, 'completed', isFalse)
            .having((s) => s.isCompleting, 'isCompleting', isFalse),
        isA<OnboardingState>().having(
          (s) => s.isCompleting,
          'isCompleting',
          isTrue,
        ),
        isA<OnboardingState>().having(
          (s) => s.completed,
          'completed',
          isTrue,
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.setOnboardingCompleted()).called(1);
      },
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'failure retains the previous completion state',
      build: () {
        when(
          () => mockRepository.isOnboardingCompleted(),
        ).thenAnswer((_) async => false);
        when(
          () => mockRepository.setOnboardingCompleted(),
        ).thenThrow(Exception('save failed'));
        return OnboardingCubit(repository: mockRepository);
      },
      act: (cubit) async {
        await cubit.stream.firstWhere(
          (s) => s.status == OnboardingStatus.resolved,
        );
        await cubit.completeOnboarding();
      },
      expect: () => [
        isA<OnboardingState>()
            .having((s) => s.status, 'status', OnboardingStatus.resolved)
            .having((s) => s.completed, 'completed', isFalse)
            .having((s) => s.isCompleting, 'isCompleting', isFalse),
        isA<OnboardingState>()
            .having((s) => s.isCompleting, 'isCompleting', isTrue)
            .having((s) => s.completed, 'completed', isFalse),
        isA<OnboardingState>()
            .having((s) => s.isCompleting, 'isCompleting', isFalse)
            .having((s) => s.completed, 'completed', isFalse)
            .having((s) => s.mutationError, 'mutationError', isNotNull),
      ],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'failure emits the safe mutation error',
      build: () {
        when(
          () => mockRepository.isOnboardingCompleted(),
        ).thenAnswer((_) async => false);
        when(
          () => mockRepository.setOnboardingCompleted(),
        ).thenThrow(Exception('save failed'));
        return OnboardingCubit(repository: mockRepository);
      },
      act: (cubit) async {
        await cubit.stream.firstWhere(
          (s) => s.status == OnboardingStatus.resolved,
        );
        await cubit.completeOnboarding();
      },
      expect: () => [
        isA<OnboardingState>()
            .having((s) => s.status, 'status', OnboardingStatus.resolved)
            .having((s) => s.completed, 'completed', isFalse)
            .having((s) => s.mutationError, 'no error while saving', isNull),
        isA<OnboardingState>()
            .having((s) => s.isCompleting, 'isCompleting', isTrue)
            .having(
              (s) => s.mutationError,
              'no error while saving',
              isNull,
            ),
        isA<OnboardingState>().having(
          (s) => s.mutationError,
          'safe error message',
          'Failed to save onboarding progress. Please try again.',
        ),
      ],
    );
  });
}
