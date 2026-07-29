// ignore_for_file: unawaited_futures

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/poem.dart';
import 'package:daily_stanza/features/share_poem/domain/model/poem_share_result.dart';
import 'package:daily_stanza/features/share_poem/domain/service/poem_share_service.dart';
import 'package:daily_stanza/features/share_poem/presentation/cubit/poem_share_cubit.dart';
import 'package:daily_stanza/features/share_poem/presentation/cubit/poem_share_state.dart';

class MockPoemShareService extends Mock implements PoemShareService {}

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
  late MockPoemShareService mockService;

  setUp(() {
    mockService = MockPoemShareService();
  });

  group('PoemShareCubit', () {
    blocTest<PoemShareCubit, PoemShareState>(
      'initial state is not sharing and has no error',
      build: () => PoemShareCubit(shareService: mockService),
      expect: () => <PoemShareState>[],
      verify: (cubit) {
        expect(cubit.state.isSharing, isFalse);
        expect(cubit.state.sharingPoemId, isNull);
        expect(cubit.state.mutationError, isNull);
      },
    );

    blocTest<PoemShareCubit, PoemShareState>(
      'share emits active sharing state',
      build: () {
        when(
          () => mockService.shareText(
            text: any(named: 'text'),
            subject: any(named: 'subject'),
            sharePositionOrigin: any(named: 'sharePositionOrigin'),
          ),
        ).thenAnswer((_) async => PoemShareResult.completed);
        return PoemShareCubit(shareService: mockService);
      },
      act: (cubit) => cubit.sharePoem(_testPoem),
      expect: () => [
        isA<PoemShareState>()
            .having((s) => s.sharingPoemId, 'sharingPoemId', 'poem1')
            .having((s) => s.isSharing, 'isSharing', isTrue)
            .having((s) => s.mutationError, 'mutationError', isNull),
        isA<PoemShareState>()
            .having((s) => s.sharingPoemId, 'sharingPoemId', isNull)
            .having((s) => s.isSharing, 'isSharing', isFalse)
            .having((s) => s.mutationError, 'mutationError', isNull),
      ],
    );

    blocTest<PoemShareCubit, PoemShareState>(
      'builder receives the Poem via text builder',
      build: () {
        when(
          () => mockService.shareText(
            text: any(named: 'text'),
            subject: any(named: 'subject'),
            sharePositionOrigin: any(named: 'sharePositionOrigin'),
          ),
        ).thenAnswer((_) async => PoemShareResult.completed);
        return PoemShareCubit(shareService: mockService);
      },
      act: (cubit) => cubit.sharePoem(_testPoem),
      verify: (cubit) {
        verify(
          () => mockService.shareText(
            text:
                'The Tyger\nby William Blake\n\n'
                'Tyger Tyger, burning bright,\nIn the forests of the night;\n\n'
                'Shared from Daily Stanza',
            subject: 'The Tyger by William Blake',
            sharePositionOrigin: any(named: 'sharePositionOrigin'),
          ),
        ).called(1);
      },
    );

    blocTest<PoemShareCubit, PoemShareState>(
      'service receives the exact text and subject built from poem',
      build: () {
        when(
          () => mockService.shareText(
            text: any(named: 'text'),
            subject: any(named: 'subject'),
            sharePositionOrigin: any(named: 'sharePositionOrigin'),
          ),
        ).thenAnswer((_) async => PoemShareResult.completed);
        return PoemShareCubit(shareService: mockService);
      },
      act: (cubit) => cubit.sharePoem(_testPoem),
      verify: (_) {
        verify(
          () => mockService.shareText(
            text:
                'The Tyger\nby William Blake\n\n'
                'Tyger Tyger, burning bright,\nIn the forests of the night;\n\n'
                'Shared from Daily Stanza',
            subject: 'The Tyger by William Blake',
            sharePositionOrigin: any(named: 'sharePositionOrigin'),
          ),
        ).called(1);
      },
    );

    blocTest<PoemShareCubit, PoemShareState>(
      'service called exactly once',
      build: () {
        when(
          () => mockService.shareText(
            text: any(named: 'text'),
            subject: any(named: 'subject'),
            sharePositionOrigin: any(named: 'sharePositionOrigin'),
          ),
        ).thenAnswer((_) async => PoemShareResult.completed);
        return PoemShareCubit(shareService: mockService);
      },
      act: (cubit) => cubit.sharePoem(_testPoem),
      verify: (_) {
        verify(
          () => mockService.shareText(
            text: any(named: 'text'),
            subject: any(named: 'subject'),
            sharePositionOrigin: any(named: 'sharePositionOrigin'),
          ),
        ).called(1);
      },
    );

    blocTest<PoemShareCubit, PoemShareState>(
      'completed clears sharing',
      build: () {
        when(
          () => mockService.shareText(
            text: any(named: 'text'),
            subject: any(named: 'subject'),
            sharePositionOrigin: any(named: 'sharePositionOrigin'),
          ),
        ).thenAnswer((_) async => PoemShareResult.completed);
        return PoemShareCubit(shareService: mockService);
      },
      act: (cubit) => cubit.sharePoem(_testPoem),
      expect: () => [
        isA<PoemShareState>().having((s) => s.isSharing, 'sharing', isTrue),
        isA<PoemShareState>()
            .having((s) => s.isSharing, 'not sharing', isFalse)
            .having((s) => s.mutationError, 'no error', isNull),
      ],
    );

    blocTest<PoemShareCubit, PoemShareState>(
      'dismissed clears sharing without error',
      build: () {
        when(
          () => mockService.shareText(
            text: any(named: 'text'),
            subject: any(named: 'subject'),
            sharePositionOrigin: any(named: 'sharePositionOrigin'),
          ),
        ).thenAnswer((_) async => PoemShareResult.dismissed);
        return PoemShareCubit(shareService: mockService);
      },
      act: (cubit) => cubit.sharePoem(_testPoem),
      expect: () => [
        isA<PoemShareState>().having((s) => s.isSharing, 'sharing', isTrue),
        isA<PoemShareState>()
            .having((s) => s.isSharing, 'not sharing', isFalse)
            .having((s) => s.mutationError, 'no error', isNull),
      ],
    );

    blocTest<PoemShareCubit, PoemShareState>(
      'unavailable clears sharing without false success',
      build: () {
        when(
          () => mockService.shareText(
            text: any(named: 'text'),
            subject: any(named: 'subject'),
            sharePositionOrigin: any(named: 'sharePositionOrigin'),
          ),
        ).thenAnswer((_) async => PoemShareResult.unavailable);
        return PoemShareCubit(shareService: mockService);
      },
      act: (cubit) => cubit.sharePoem(_testPoem),
      expect: () => [
        isA<PoemShareState>().having((s) => s.isSharing, 'sharing', isTrue),
        isA<PoemShareState>()
            .having((s) => s.isSharing, 'not sharing', isFalse)
            .having((s) => s.mutationError, 'no error', isNull),
      ],
    );

    blocTest<PoemShareCubit, PoemShareState>(
      'thrown error emits safe message',
      build: () {
        when(
          () => mockService.shareText(
            text: any(named: 'text'),
            subject: any(named: 'subject'),
            sharePositionOrigin: any(named: 'sharePositionOrigin'),
          ),
        ).thenThrow(Exception('hidden'));
        return PoemShareCubit(shareService: mockService);
      },
      act: (cubit) => cubit.sharePoem(_testPoem),
      expect: () => [
        isA<PoemShareState>()
            .having((s) => s.sharingPoemId, 'sharingPoemId', 'poem1')
            .having((s) => s.isSharing, 'isSharing', isTrue),
        isA<PoemShareState>()
            .having((s) => s.isSharing, 'isSharing', isFalse)
            .having(
              (s) => s.mutationError,
              'mutationError',
              'Unable to share poem. Please try again.',
            ),
      ],
    );

    blocTest<PoemShareCubit, PoemShareState>(
      'rapid duplicate taps are guarded',
      build: () {
        when(
          () => mockService.shareText(
            text: any(named: 'text'),
            subject: any(named: 'subject'),
            sharePositionOrigin: any(named: 'sharePositionOrigin'),
          ),
        ).thenAnswer((_) async => PoemShareResult.completed);
        return PoemShareCubit(shareService: mockService);
      },
      act: (cubit) async {
        // Fire two rapid shares; the second should be ignored.
        final futures = [
          cubit.sharePoem(_testPoem),
          cubit.sharePoem(_testPoem),
        ];
        await Future.wait(futures);
      },
      verify: (_) {
        verify(
          () => mockService.shareText(
            text: any(named: 'text'),
            subject: any(named: 'subject'),
            sharePositionOrigin: any(named: 'sharePositionOrigin'),
          ),
        ).called(1);
      },
    );

    blocTest<PoemShareCubit, PoemShareState>(
      'second share works after the first completes',
      build: () {
        when(
          () => mockService.shareText(
            text: any(named: 'text'),
            subject: any(named: 'subject'),
            sharePositionOrigin: any(named: 'sharePositionOrigin'),
          ),
        ).thenAnswer((_) async => PoemShareResult.completed);
        return PoemShareCubit(shareService: mockService);
      },
      act: (cubit) async {
        await cubit.sharePoem(_testPoem);
        await cubit.sharePoem(_testPoem);
      },
      verify: (_) {
        verify(
          () => mockService.shareText(
            text: any(named: 'text'),
            subject: any(named: 'subject'),
            sharePositionOrigin: any(named: 'sharePositionOrigin'),
          ),
        ).called(2);
      },
    );

    blocTest<PoemShareCubit, PoemShareState>(
      'two identical failures are observable separately',
      build: () {
        when(
          () => mockService.shareText(
            text: any(named: 'text'),
            subject: any(named: 'subject'),
            sharePositionOrigin: any(named: 'sharePositionOrigin'),
          ),
        ).thenThrow(Exception('hidden'));
        return PoemShareCubit(shareService: mockService);
      },
      act: (cubit) async {
        await cubit.sharePoem(_testPoem);
        await cubit.sharePoem(_testPoem);
      },
      expect: () => [
        // First attempt
        isA<PoemShareState>().having((s) => s.isSharing, 'sharing 1', isTrue),
        isA<PoemShareState>()
            .having((s) => s.isSharing, 'not sharing 1', isFalse)
            .having((s) => s.mutationError, 'error 1', isNotNull),
        // Error is cleared before second attempt
        isA<PoemShareState>()
            .having((s) => s.mutationError, 'error cleared', isNull)
            .having((s) => s.isSharing, 'not sharing', isFalse),
        // Second attempt
        isA<PoemShareState>().having((s) => s.isSharing, 'sharing 2', isTrue),
        isA<PoemShareState>()
            .having((s) => s.isSharing, 'not sharing 2', isFalse)
            .having((s) => s.mutationError, 'error 2', isNotNull),
      ],
    );

    blocTest<PoemShareCubit, PoemShareState>(
      'success after failure clears old error',
      build: () {
        when(
          () => mockService.shareText(
            text: any(named: 'text'),
            subject: any(named: 'subject'),
            sharePositionOrigin: any(named: 'sharePositionOrigin'),
          ),
        ).thenAnswer((_) async => PoemShareResult.completed);
        return PoemShareCubit(shareService: mockService);
      },
      act: (cubit) async {
        // First failure
        when(
          () => mockService.shareText(
            text: any(named: 'text'),
            subject: any(named: 'subject'),
            sharePositionOrigin: any(named: 'sharePositionOrigin'),
          ),
        ).thenThrow(Exception('hidden'));
        await cubit.sharePoem(_testPoem);
        // Second success
        when(
          () => mockService.shareText(
            text: any(named: 'text'),
            subject: any(named: 'subject'),
            sharePositionOrigin: any(named: 'sharePositionOrigin'),
          ),
        ).thenAnswer((_) async => PoemShareResult.completed);
        await cubit.sharePoem(_testPoem);
      },
      expect: () => [
        isA<PoemShareState>().having((s) => s.isSharing, 'sharing 1', isTrue),
        isA<PoemShareState>()
            .having((s) => s.isSharing, 'not sharing 1', isFalse)
            .having((s) => s.mutationError, 'error 1', isNotNull),
        // Error is cleared before second attempt
        isA<PoemShareState>()
            .having((s) => s.mutationError, 'error cleared', isNull)
            .having((s) => s.isSharing, 'not sharing', isFalse),
        isA<PoemShareState>()
            .having((s) => s.isSharing, 'sharing 2', isTrue)
            .having((s) => s.mutationError, 'no error', isNull),
        isA<PoemShareState>()
            .having((s) => s.isSharing, 'not sharing 2', isFalse)
            .having((s) => s.mutationError, 'no error', isNull),
      ],
    );
  });
}
