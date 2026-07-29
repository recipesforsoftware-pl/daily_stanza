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
import 'package:daily_stanza/features/settings/domain/model/poem_language.dart';
import 'package:daily_stanza/features/settings/domain/model/theme_preference.dart';
import 'package:daily_stanza/features/settings/domain/repository/language_preferences_repository.dart';
import 'package:daily_stanza/features/settings/domain/repository/theme_preferences_repository.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/language_preferences_cubit.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/language_preferences_state.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/theme_preferences_cubit.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/theme_preferences_state.dart';

class _MockPoemRepository extends Mock implements PoemRepository {}

class _MockLanguagePreferencesRepository extends Mock
    implements LanguagePreferencesRepository {}

class _MockThemePreferencesRepository extends Mock
    implements ThemePreferencesRepository {}

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

const _expectedError = 'Failed to save theme preference. Please try again.';

/// Builds the same root-level composition as main.dart:
///
///   RepositoryProvider<PoemRepository>
///     MultiBlocProvider
///       BlocProvider<FavouritesCubit>
///       BlocProvider<LanguagePreferencesCubit>
///       BlocProvider<ThemePreferencesCubit>
///         MultiBlocListener
///           BlocListener<FavouritesCubit> (global listener)
///           BlocListener<LanguagePreferencesCubit> (global listener)
///           BlocListener<ThemePreferencesCubit> (global listener)
///             MaterialApp.router(routerConfig: appRouter, scaffoldMessengerKey)
Widget _buildApp({
  required PoemRepository poemRepository,
  required FavouritesCubit favouritesCubit,
  required LanguagePreferencesCubit languagePreferencesCubit,
  required ThemePreferencesCubit themePreferencesCubit,
  required GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
}) {
  return RepositoryProvider<PoemRepository>.value(
    value: poemRepository,
    child: MultiBlocProvider(
      providers: [
        BlocProvider<FavouritesCubit>.value(value: favouritesCubit),
        BlocProvider<LanguagePreferencesCubit>.value(
          value: languagePreferencesCubit,
        ),
        BlocProvider<ThemePreferencesCubit>.value(value: themePreferencesCubit),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<FavouritesCubit, FavouritesState>(
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
          ),
          BlocListener<LanguagePreferencesCubit, LanguagePreferencesState>(
            listenWhen: (previous, current) {
              return current.mutationError != null &&
                  current.mutationError != previous.mutationError;
            },
            listener: (context, state) {
              final error = state.mutationError;
              if (error == null) return;
              scaffoldMessengerKey.currentState
                ?..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(error)));
            },
          ),
          BlocListener<ThemePreferencesCubit, ThemePreferencesState>(
            listenWhen: (previous, current) {
              return current.mutationError != null &&
                  current.mutationError != previous.mutationError;
            },
            listener: (context, state) {
              final error = state.mutationError;
              if (error == null) return;
              scaffoldMessengerKey.currentState
                ?..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(error)));
            },
          ),
        ],
        child: MaterialApp.router(
          scaffoldMessengerKey: scaffoldMessengerKey,
          routerConfig: appRouter,
        ),
      ),
    ),
  );
}

void main() {
  late _MockPoemRepository mockRepo;
  late _MockFavouritesCubit mockFavCubit;
  late _MockLanguagePreferencesRepository mockLangRepo;
  late _MockThemePreferencesRepository mockThemeRepo;
  late GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  setUpAll(() {
    registerFallbackValue(PoemLanguage.english);
    registerFallbackValue(PoemLanguage.polish);
    registerFallbackValue(ThemePreference.system);
    registerFallbackValue(ThemePreference.light);
    registerFallbackValue(ThemePreference.dark);
  });

  setUp(() {
    mockRepo = _MockPoemRepository();
    mockFavCubit = _MockFavouritesCubit();
    mockLangRepo = _MockLanguagePreferencesRepository();
    mockThemeRepo = _MockThemePreferencesRepository();
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

  group('Theme preference mutation error presentation', () {
    testWidgets('one theme mutation error shows one SnackBar', (tester) async {
      whenListen(
        mockFavCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );

      final themeCubit = ThemePreferencesCubit(
        repository: mockThemeRepo,
        initialPreference: ThemePreference.system,
      );
      final langCubit = LanguagePreferencesCubit(
        repository: mockLangRepo,
        initialLanguage: PoemLanguage.english,
      );

      await tester.pumpWidget(
        _buildApp(
          poemRepository: mockRepo,
          favouritesCubit: mockFavCubit,
          languagePreferencesCubit: langCubit,
          themePreferencesCubit: themeCubit,
          scaffoldMessengerKey: scaffoldMessengerKey,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Emit a mutation error via the cubit
      themeCubit.emit(
        const ThemePreferencesState(
          preference: ThemePreference.system,
          mutationError: _expectedError,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(_expectedError), findsOneWidget);
      await themeCubit.close();
      await langCubit.close();
    });

    testWidgets('exact safe message is shown', (tester) async {
      whenListen(
        mockFavCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );
      when(
        () => mockThemeRepo.setPreferredTheme(any()),
      ).thenThrow(Exception('fail'));

      final themeCubit = ThemePreferencesCubit(
        repository: mockThemeRepo,
        initialPreference: ThemePreference.system,
      );
      final langCubit = LanguagePreferencesCubit(
        repository: mockLangRepo,
        initialLanguage: PoemLanguage.english,
      );

      await tester.pumpWidget(
        _buildApp(
          poemRepository: mockRepo,
          favouritesCubit: mockFavCubit,
          languagePreferencesCubit: langCubit,
          themePreferencesCubit: themeCubit,
          scaffoldMessengerKey: scaffoldMessengerKey,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      await themeCubit.changeTheme(ThemePreference.dark);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(_expectedError), findsOneWidget);
      await themeCubit.close();
      await langCubit.close();
    });

    testWidgets('clean state shows no SnackBar', (tester) async {
      whenListen(
        mockFavCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );

      final themeCubit = ThemePreferencesCubit(
        repository: mockThemeRepo,
        initialPreference: ThemePreference.system,
      );
      final langCubit = LanguagePreferencesCubit(
        repository: mockLangRepo,
        initialLanguage: PoemLanguage.english,
      );

      await tester.pumpWidget(
        _buildApp(
          poemRepository: mockRepo,
          favouritesCubit: mockFavCubit,
          languagePreferencesCubit: langCubit,
          themePreferencesCubit: themeCubit,
          scaffoldMessengerKey: scaffoldMessengerKey,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text(_expectedError), findsNothing);
      await themeCubit.close();
      await langCubit.close();
    });

    testWidgets('old error is not repeated on rebuild', (tester) async {
      whenListen(
        mockFavCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );

      final themeCubit = ThemePreferencesCubit(
        repository: mockThemeRepo,
        initialPreference: ThemePreference.system,
      );
      final langCubit = LanguagePreferencesCubit(
        repository: mockLangRepo,
        initialLanguage: PoemLanguage.english,
      );

      // Emit error first (as initial state would have it)
      themeCubit.emit(
        const ThemePreferencesState(
          preference: ThemePreference.system,
          mutationError: _expectedError,
        ),
      );

      await tester.pumpWidget(
        _buildApp(
          poemRepository: mockRepo,
          favouritesCubit: mockFavCubit,
          languagePreferencesCubit: langCubit,
          themePreferencesCubit: themeCubit,
          scaffoldMessengerKey: scaffoldMessengerKey,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // The listener only fires on *changes*, not initial state, so no SnackBar.
      expect(find.text(_expectedError), findsNothing);
      await themeCubit.close();
      await langCubit.close();
    });

    testWidgets('two separate failures each show one SnackBar', (tester) async {
      whenListen(
        mockFavCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );

      final themeCubit = ThemePreferencesCubit(
        repository: mockThemeRepo,
        initialPreference: ThemePreference.system,
      );
      final langCubit = LanguagePreferencesCubit(
        repository: mockLangRepo,
        initialLanguage: PoemLanguage.english,
      );

      await tester.pumpWidget(
        _buildApp(
          poemRepository: mockRepo,
          favouritesCubit: mockFavCubit,
          languagePreferencesCubit: langCubit,
          themePreferencesCubit: themeCubit,
          scaffoldMessengerKey: scaffoldMessengerKey,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // First error
      themeCubit.emit(
        const ThemePreferencesState(
          preference: ThemePreference.system,
          mutationError: _expectedError,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text(_expectedError), findsOneWidget);

      // Clear error
      themeCubit.emit(
        const ThemePreferencesState(
          preference: ThemePreference.system,
          mutationError: null,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Second error
      themeCubit.emit(
        const ThemePreferencesState(
          preference: ThemePreference.system,
          mutationError: _expectedError,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should still have one SnackBar (the second one)
      expect(find.text(_expectedError), findsOneWidget);
      await themeCubit.close();
      await langCubit.close();
    });

    testWidgets('favourite error does not show theme message', (tester) async {
      whenListen(
        mockFavCubit,
        Stream.fromIterable([
          const FavouritesLoaded(
            poems: [_testPoem],
            favouriteIds: {'poem1'},
            mutationError: 'Failed to save. Please try again.',
          ),
        ]),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );

      final themeCubit = ThemePreferencesCubit(
        repository: mockThemeRepo,
        initialPreference: ThemePreference.system,
      );
      final langCubit = LanguagePreferencesCubit(
        repository: mockLangRepo,
        initialLanguage: PoemLanguage.english,
      );

      await tester.pumpWidget(
        _buildApp(
          poemRepository: mockRepo,
          favouritesCubit: mockFavCubit,
          languagePreferencesCubit: langCubit,
          themePreferencesCubit: themeCubit,
          scaffoldMessengerKey: scaffoldMessengerKey,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Favourites error should produce its SnackBar
      expect(find.text('Failed to save. Please try again.'), findsOneWidget);
      // Theme error should not be shown
      expect(find.text(_expectedError), findsNothing);
      await themeCubit.close();
      await langCubit.close();
    });

    testWidgets('language error does not show theme message', (tester) async {
      whenListen(
        mockFavCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );

      final themeCubit = ThemePreferencesCubit(
        repository: mockThemeRepo,
        initialPreference: ThemePreference.system,
      );
      final langCubit = LanguagePreferencesCubit(
        repository: mockLangRepo,
        initialLanguage: PoemLanguage.english,
      );

      await tester.pumpWidget(
        _buildApp(
          poemRepository: mockRepo,
          favouritesCubit: mockFavCubit,
          languagePreferencesCubit: langCubit,
          themePreferencesCubit: themeCubit,
          scaffoldMessengerKey: scaffoldMessengerKey,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Emit a language mutation error
      langCubit.emit(
        const LanguagePreferencesState(
          language: PoemLanguage.english,
          mutationError:
              'Failed to save language preference. Please try again.',
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Language error should show
      expect(
        find.text('Failed to save language preference. Please try again.'),
        findsOneWidget,
      );
      // Theme error should not be shown
      expect(find.text(_expectedError), findsNothing);
      await themeCubit.close();
      await langCubit.close();
    });
  });
}
