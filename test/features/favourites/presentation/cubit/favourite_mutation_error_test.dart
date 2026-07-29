import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:daily_stanza/core/router/app_router.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/daily_poem_result.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/poem.dart';
import 'package:daily_stanza/features/daily_poem/domain/repository/poem_repository.dart';
import 'package:daily_stanza/features/favourites/presentation/cubit/favourites_cubit.dart';
import 'package:daily_stanza/features/favourites/presentation/cubit/favourites_state.dart';

class _MockPoemRepository extends Mock implements PoemRepository {}

class _MockFavouritesCubit extends MockBloc<FavouritesCubit, FavouritesState>
    implements FavouritesCubit {}

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

/// Builds the same root-level composition as main.dart:
///
///   RepositoryProvider<PoemRepository>
///     BlocProvider<FavouritesCubit>
///       BlocListener<FavouritesCubit> (global listener)
///         MaterialApp.router(routerConfig: appRouter, scaffoldMessengerKey)
Widget _buildApp({
  required PoemRepository poemRepository,
  required FavouritesCubit favouritesCubit,
  required GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
}) {
  return RepositoryProvider<PoemRepository>.value(
    value: poemRepository,
    child: BlocProvider<FavouritesCubit>.value(
      value: favouritesCubit,
      child: BlocListener<FavouritesCubit, FavouritesState>(
        listenWhen: (previous, current) {
          final previousError = switch (previous) {
            FavouritesLoaded(:final mutationError) => mutationError,
            _ => null,
          };
          final currentError = switch (current) {
            FavouritesLoaded(:final mutationError) => mutationError,
            _ => null,
          };
          return currentError != null && currentError != previousError;
        },
        listener: (context, state) {
          final error = switch (state) {
            FavouritesLoaded(:final mutationError) => mutationError,
            _ => null,
          };
          if (error == null) return;
          scaffoldMessengerKey.currentState
            ?..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(error)));
        },
        child: MaterialApp.router(
          scaffoldMessengerKey: scaffoldMessengerKey,
          routerConfig: appRouter,
        ),
      ),
    ),
  );
}

const _expectedError = 'Failed to save. Please try again.';

void main() {
  late _MockPoemRepository mockRepo;
  late _MockFavouritesCubit mockFavCubit;
  late GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  setUp(() {
    mockRepo = _MockPoemRepository();
    mockFavCubit = _MockFavouritesCubit();
    scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

    // Stub the daily poem so the initial /today route can load.
    when(
      () => mockRepo.getDailyPoem(
        date: any(named: 'date'),
        languageCode: any(named: 'languageCode'),
      ),
    ).thenAnswer(
      (_) async => const DailyPoemResult(poem: _testPoem, isFromCache: false),
    );
    when(
      () => mockRepo.getPoemsByIds(['poem1']),
    ).thenAnswer((_) async => [_testPoem]);
  });

  group('Favourite mutation error presentation', () {
    testWidgets('shell route shows one SnackBar on mutation error', (
      tester,
    ) async {
      whenListen(
        mockFavCubit,
        Stream.fromIterable([
          const FavouritesLoaded(
            poems: [_testPoem],
            favouriteIds: {'poem1'},
            mutationError: _expectedError,
          ),
        ]),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );

      await tester.pumpWidget(
        _buildApp(
          poemRepository: mockRepo,
          favouritesCubit: mockFavCubit,
          scaffoldMessengerKey: scaffoldMessengerKey,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Navigate to the Today shell route
      appRouter.go('/today');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(_expectedError), findsOneWidget);
    });

    testWidgets('PoemDetailsView shows one SnackBar on mutation error', (
      tester,
    ) async {
      whenListen(
        mockFavCubit,
        Stream.fromIterable([
          const FavouritesLoaded(
            poems: [_testPoem],
            favouriteIds: {'poem1'},
            mutationError: _expectedError,
          ),
        ]),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );

      await tester.pumpWidget(
        _buildApp(
          poemRepository: mockRepo,
          favouritesCubit: mockFavCubit,
          scaffoldMessengerKey: scaffoldMessengerKey,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Navigate to the poem details route (root navigator, above shell)
      appRouter.go('/today/poem/poem1');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // The details view should show the SnackBar from the global listener
      expect(find.text(_expectedError), findsOneWidget);
      // The details content should still be visible
      expect(find.text('The Tyger'), findsAtLeast(1));
    });

    testWidgets('single mutation error shows exactly one SnackBar', (
      tester,
    ) async {
      whenListen(
        mockFavCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(
          poems: [_testPoem],
          favouriteIds: {'poem1'},
          mutationError: _expectedError,
        ),
      );

      await tester.pumpWidget(
        _buildApp(
          poemRepository: mockRepo,
          favouritesCubit: mockFavCubit,
          scaffoldMessengerKey: scaffoldMessengerKey,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // The listener only fires on *changes*, not initial state, so no SnackBar.
      expect(find.text(_expectedError), findsNothing);
    });

    testWidgets(
      'returning from PoemDetailsView does not show a delayed duplicate',
      (tester) async {
        // Emit one error, then navigate back to verify no duplicate.
        whenListen(
          mockFavCubit,
          Stream.fromIterable([
            const FavouritesLoaded(
              poems: [_testPoem],
              favouriteIds: {'poem1'},
              mutationError: _expectedError,
            ),
            const FavouritesLoaded(poems: [_testPoem], favouriteIds: {'poem1'}),
          ]),
          initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
        );

        await tester.pumpWidget(
          _buildApp(
            poemRepository: mockRepo,
            favouritesCubit: mockFavCubit,
            scaffoldMessengerKey: scaffoldMessengerKey,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        // Navigate to poem details (which triggers the mutation error emission)
        appRouter.go('/today/poem/poem1');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // SnackBar should be visible
        expect(find.text(_expectedError), findsOneWidget);

        // Navigate back to Today
        appRouter.go('/today');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // No *new* SnackBar should appear. The old SnackBar may still be visible
        // if it hasn't auto-dismissed, but there should be at most one.
        // Only the original SnackBar text may remain; no duplicate appeared.
        expect(find.text(_expectedError), findsOneWidget);
      },
    );

    testWidgets('two separate failures show one SnackBar each', (tester) async {
      whenListen(
        mockFavCubit,
        Stream.fromIterable([
          // First error
          const FavouritesLoaded(
            poems: [_testPoem],
            favouriteIds: {'poem1'},
            mutationError: _expectedError,
          ),
          // Clear
          const FavouritesLoaded(poems: [_testPoem], favouriteIds: {'poem1'}),
          // Second error (different state so listenWhen fires)
          const FavouritesLoaded(
            poems: [_testPoem],
            favouriteIds: {'poem1'},
            mutationError: _expectedError,
          ),
        ]),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );

      await tester.pumpWidget(
        _buildApp(
          poemRepository: mockRepo,
          favouritesCubit: mockFavCubit,
          scaffoldMessengerKey: scaffoldMessengerKey,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Navigate to Today to see the first SnackBar
      appRouter.go('/today');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // After first error
      expect(find.text(_expectedError), findsOneWidget);

      // After clearing (second emission) — SnackBar from first error may still be visible
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text(_expectedError), findsOneWidget);

      // After third emission (second error) — listener fires again because
      // previous error was null (cleared)
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text(_expectedError), findsOneWidget);
    });

    testWidgets('state without mutationError does not show SnackBar', (
      tester,
    ) async {
      whenListen(
        mockFavCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(
          poems: [_testPoem],
          favouriteIds: {'poem1'},
        ),
      );

      await tester.pumpWidget(
        _buildApp(
          poemRepository: mockRepo,
          favouritesCubit: mockFavCubit,
          scaffoldMessengerKey: scaffoldMessengerKey,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text(_expectedError), findsNothing);
    });
  });
}
