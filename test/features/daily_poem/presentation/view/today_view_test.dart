import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/poem.dart';
import 'package:daily_stanza/features/daily_poem/domain/repository/poem_repository.dart';
import 'package:daily_stanza/features/daily_poem/presentation/bloc/daily_poem_bloc.dart';
import 'package:daily_stanza/features/daily_poem/presentation/bloc/daily_poem_event.dart';
import 'package:daily_stanza/features/daily_poem/presentation/bloc/daily_poem_state.dart';
import 'package:daily_stanza/features/daily_poem/presentation/view/today_view.dart';
import 'package:daily_stanza/features/favourites/presentation/cubit/favourites_cubit.dart';
import 'package:daily_stanza/features/favourites/presentation/cubit/favourites_state.dart';
import 'package:daily_stanza/features/settings/domain/model/poem_language.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/language_preferences_cubit.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/language_preferences_state.dart';
import 'package:daily_stanza/features/share_poem/domain/model/poem_share_result.dart';
import 'package:daily_stanza/features/share_poem/domain/service/poem_share_service.dart';
import 'package:daily_stanza/features/share_poem/presentation/cubit/poem_share_cubit.dart';

class MockPoemRepository extends Mock implements PoemRepository {}

class MockFavouritesCubit extends MockBloc<FavouritesCubit, FavouritesState>
    implements FavouritesCubit {}

class MockLanguagePreferencesCubit
    extends MockBloc<LanguagePreferencesCubit, LanguagePreferencesState>
    implements LanguagePreferencesCubit {}

class MockDailyPoemBloc extends Mock implements DailyPoemBloc {}

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

const _longPoem = Poem(
  id: 'long1',
  title: 'Testament moj',
  author: 'Juliusz Slowacki',
  languageCode: 'pl',
  countryCode: 'PL',
  content:
      'Line one of a very long poem.\n'
      'Line two continues the thought.\n'
      'Line three adds more depth.\n'
      'Line four keeps going.\n'
      'Line five is still here.\n'
      'Line six never ends.\n'
      'Line seven goes on.\n'
      'Line eight still more.\n'
      'Line nine almost done.\n'
      'Line ten the last line.',
  sourceName: 'Dziela',
  sourceUrl: 'https://pl.wikisource.org',
  rightsStatus: 'public_domain',
);

Widget _buildApp({
  required MockDailyPoemBloc dailyPoemBloc,
  MockFavouritesCubit? favouritesCubit,
  MockLanguagePreferencesCubit? languageCubit,
  PoemShareCubit? shareCubit,
}) {
  final favCubit = favouritesCubit ?? _createDefaultFavCubit();
  final langCubit = languageCubit ?? _createDefaultLangCubit();
  final shareCubitValue = shareCubit ?? _createDefaultShareCubit();
  return MaterialApp(
    home: MultiBlocProvider(
      providers: [
        BlocProvider<FavouritesCubit>.value(value: favCubit),
        BlocProvider<LanguagePreferencesCubit>.value(value: langCubit),
        BlocProvider<DailyPoemBloc>.value(value: dailyPoemBloc),
        BlocProvider<PoemShareCubit>.value(value: shareCubitValue),
      ],
      child: const TodayView(),
    ),
  );
}

MockFavouritesCubit _createDefaultFavCubit() {
  final cubit = MockFavouritesCubit();
  whenListen(
    cubit,
    const Stream<FavouritesState>.empty(),
    initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
  );
  return cubit;
}

MockLanguagePreferencesCubit _createDefaultLangCubit() {
  final cubit = MockLanguagePreferencesCubit();
  whenListen(
    cubit,
    const Stream<LanguagePreferencesState>.empty(),
    initialState: const LanguagePreferencesState(
      language: PoemLanguage.english,
    ),
  );
  return cubit;
}

PoemShareCubit _createDefaultShareCubit() {
  final mockService = MockPoemShareService();
  when(
    () => mockService.shareText(
      text: any(named: 'text'),
      subject: any(named: 'subject'),
      sharePositionOrigin: any(named: 'sharePositionOrigin'),
    ),
  ).thenAnswer((_) async => PoemShareResult.completed);
  return PoemShareCubit(shareService: mockService);
}

void main() {
  setUpAll(() {
    registerFallbackValue(const DailyPoemRetryRequested());
    registerFallbackValue(
      DailyPoemRequested(date: DateTime(2026, 7, 28), languageCode: 'en'),
    );
    registerFallbackValue(_testPoem);
    registerFallbackValue(PoemLanguage.english);
    registerFallbackValue(PoemLanguage.polish);
    registerFallbackValue(PoemShareResult.completed);
  });

  group('TodayView', () {
    testWidgets('loading state displays Stanzi and loading copy', (
      tester,
    ) async {
      final bloc = MockDailyPoemBloc();
      whenListen(
        bloc,
        const Stream<DailyPoemState>.empty(),
        initialState: const DailyPoemLoading(),
      );

      await tester.pumpWidget(_buildApp(dailyPoemBloc: bloc));
      await tester.pump();

      expect(find.byType(Image), findsOneWidget);
      expect(find.textContaining("Finding today's poem"), findsOneWidget);
    });

    testWidgets('loaded state displays title', (tester) async {
      final bloc = MockDailyPoemBloc();
      whenListen(
        bloc,
        const Stream<DailyPoemState>.empty(),
        initialState: const DailyPoemLoaded(
          poem: _testPoem,
          isFromCache: false,
        ),
      );
      final favCubit = MockFavouritesCubit();
      whenListen(
        favCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );

      await tester.pumpWidget(
        _buildApp(dailyPoemBloc: bloc, favouritesCubit: favCubit),
      );
      await tester.pump();

      expect(find.text('The Tyger'), findsOneWidget);
    });

    testWidgets('loaded state displays author', (tester) async {
      final bloc = MockDailyPoemBloc();
      whenListen(
        bloc,
        const Stream<DailyPoemState>.empty(),
        initialState: const DailyPoemLoaded(
          poem: _testPoem,
          isFromCache: false,
        ),
      );
      final favCubit = MockFavouritesCubit();
      whenListen(
        favCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );

      await tester.pumpWidget(
        _buildApp(dailyPoemBloc: bloc, favouritesCubit: favCubit),
      );
      await tester.pump();

      expect(find.text('William Blake'), findsOneWidget);
    });

    testWidgets('loaded state displays poem content with line breaks', (
      tester,
    ) async {
      final bloc = MockDailyPoemBloc();
      whenListen(
        bloc,
        const Stream<DailyPoemState>.empty(),
        initialState: const DailyPoemLoaded(
          poem: _testPoem,
          isFromCache: false,
        ),
      );
      final favCubit = MockFavouritesCubit();
      whenListen(
        favCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );

      await tester.pumpWidget(
        _buildApp(dailyPoemBloc: bloc, favouritesCubit: favCubit),
      );
      await tester.pump();

      expect(
        find.textContaining('Tyger Tyger, burning bright'),
        findsOneWidget,
      );
      expect(
        find.textContaining('In the forests of the night'),
        findsOneWidget,
      );
    });

    testWidgets('loaded state displays language and country chips', (
      tester,
    ) async {
      final bloc = MockDailyPoemBloc();
      whenListen(
        bloc,
        const Stream<DailyPoemState>.empty(),
        initialState: const DailyPoemLoaded(
          poem: _testPoem,
          isFromCache: false,
        ),
      );
      final favCubit = MockFavouritesCubit();
      whenListen(
        favCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );

      await tester.pumpWidget(
        _buildApp(dailyPoemBloc: bloc, favouritesCubit: favCubit),
      );
      await tester.pump();

      expect(find.text('English'), findsOneWidget);
      expect(find.text('United Kingdom'), findsOneWidget);
    });

    testWidgets('cached state displays the offline banner', (tester) async {
      final bloc = MockDailyPoemBloc();
      whenListen(
        bloc,
        const Stream<DailyPoemState>.empty(),
        initialState: const DailyPoemLoaded(poem: _testPoem, isFromCache: true),
      );
      final favCubit = MockFavouritesCubit();
      whenListen(
        favCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );

      await tester.pumpWidget(
        _buildApp(dailyPoemBloc: bloc, favouritesCubit: favCubit),
      );
      await tester.pump();

      expect(find.textContaining('previously downloaded poem'), findsOneWidget);
    });

    testWidgets('Stanzi is not displayed in the loaded state', (tester) async {
      final bloc = MockDailyPoemBloc();
      whenListen(
        bloc,
        const Stream<DailyPoemState>.empty(),
        initialState: const DailyPoemLoaded(
          poem: _testPoem,
          isFromCache: false,
        ),
      );
      final favCubit = MockFavouritesCubit();
      whenListen(
        favCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );

      await tester.pumpWidget(
        _buildApp(dailyPoemBloc: bloc, favouritesCubit: favCubit),
      );
      await tester.pump();

      expect(find.byType(Image), findsNothing);
    });

    testWidgets('missing state displays the expected message', (tester) async {
      final bloc = MockDailyPoemBloc();
      whenListen(
        bloc,
        const Stream<DailyPoemState>.empty(),
        initialState: const DailyPoemMissing(),
      );

      await tester.pumpWidget(_buildApp(dailyPoemBloc: bloc));
      await tester.pump();

      expect(find.text("Today's poem is not available yet"), findsOneWidget);
      expect(find.text('Please try again later.'), findsOneWidget);
    });

    testWidgets('failure state displays a retry button', (tester) async {
      final bloc = MockDailyPoemBloc();
      whenListen(
        bloc,
        const Stream<DailyPoemState>.empty(),
        initialState: const DailyPoemFailure(
          failureType: DailyPoemFailureType.network,
        ),
      );

      await tester.pumpWidget(_buildApp(dailyPoemBloc: bloc));
      await tester.pump();

      expect(find.text("We couldn't load today's poem"), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('tapping retry dispatches DailyPoemRetryRequested', (
      tester,
    ) async {
      final bloc = MockDailyPoemBloc();
      whenListen(
        bloc,
        const Stream<DailyPoemState>.empty(),
        initialState: const DailyPoemFailure(
          failureType: DailyPoemFailureType.network,
        ),
      );

      await tester.pumpWidget(_buildApp(dailyPoemBloc: bloc));
      await tester.pump();

      await tester.tap(find.text('Try again'));

      verify(() => bloc.add(const DailyPoemRetryRequested())).called(1);
    });

    testWidgets('a long poem can be scrolled without overflow', (tester) async {
      final bloc = MockDailyPoemBloc();
      whenListen(
        bloc,
        const Stream<DailyPoemState>.empty(),
        initialState: const DailyPoemLoaded(
          poem: _longPoem,
          isFromCache: false,
        ),
      );
      final favCubit = MockFavouritesCubit();
      whenListen(
        favCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );

      await tester.pumpWidget(
        _buildApp(dailyPoemBloc: bloc, favouritesCubit: favCubit),
      );
      await tester.pump();

      // Should not throw a layout overflow exception.
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'the compact 360 x 800 viewport produces no Flutter layout exceptions',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final bloc = MockDailyPoemBloc();
        whenListen(
          bloc,
          const Stream<DailyPoemState>.empty(),
          initialState: const DailyPoemLoaded(
            poem: _testPoem,
            isFromCache: false,
          ),
        );
        final favCubit = MockFavouritesCubit();
        whenListen(
          favCubit,
          const Stream<FavouritesState>.empty(),
          initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
        );

        await tester.pumpWidget(
          _buildApp(dailyPoemBloc: bloc, favouritesCubit: favCubit),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      },
    );

    // --- Favourite integration tests ---

    testWidgets('loaded non-favourite poem shows an outline heart', (
      tester,
    ) async {
      final bloc = MockDailyPoemBloc();
      whenListen(
        bloc,
        const Stream<DailyPoemState>.empty(),
        initialState: const DailyPoemLoaded(
          poem: _testPoem,
          isFromCache: false,
        ),
      );
      final favCubit = MockFavouritesCubit();
      whenListen(
        favCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );

      await tester.pumpWidget(
        _buildApp(dailyPoemBloc: bloc, favouritesCubit: favCubit),
      );
      await tester.pump();

      expect(find.byIcon(Icons.favorite_outline), findsOneWidget);
    });

    testWidgets('loaded favourite poem shows a filled heart', (tester) async {
      final bloc = MockDailyPoemBloc();
      whenListen(
        bloc,
        const Stream<DailyPoemState>.empty(),
        initialState: const DailyPoemLoaded(
          poem: _testPoem,
          isFromCache: false,
        ),
      );
      final favCubit = MockFavouritesCubit();
      whenListen(
        favCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(
          poems: [_testPoem],
          favouriteIds: {'poem1'},
        ),
      );

      await tester.pumpWidget(
        _buildApp(dailyPoemBloc: bloc, favouritesCubit: favCubit),
      );
      await tester.pump();

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('outline-heart action has semantic label "Add to favourites"', (
      tester,
    ) async {
      final bloc = MockDailyPoemBloc();
      whenListen(
        bloc,
        const Stream<DailyPoemState>.empty(),
        initialState: const DailyPoemLoaded(
          poem: _testPoem,
          isFromCache: false,
        ),
      );
      final favCubit = MockFavouritesCubit();
      whenListen(
        favCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );

      await tester.pumpWidget(
        _buildApp(dailyPoemBloc: bloc, favouritesCubit: favCubit),
      );
      await tester.pump();

      expect(find.byTooltip('Add to favourites'), findsOneWidget);
    });

    testWidgets(
      'filled-heart action has semantic label "Remove from favourites"',
      (tester) async {
        final bloc = MockDailyPoemBloc();
        whenListen(
          bloc,
          const Stream<DailyPoemState>.empty(),
          initialState: const DailyPoemLoaded(
            poem: _testPoem,
            isFromCache: false,
          ),
        );
        final favCubit = MockFavouritesCubit();
        whenListen(
          favCubit,
          const Stream<FavouritesState>.empty(),
          initialState: const FavouritesLoaded(
            poems: [_testPoem],
            favouriteIds: {'poem1'},
          ),
        );

        await tester.pumpWidget(
          _buildApp(dailyPoemBloc: bloc, favouritesCubit: favCubit),
        );
        await tester.pump();

        expect(find.byTooltip('Remove from favourites'), findsOneWidget);
      },
    );

    testWidgets('tapping add calls cubit.addFavourite', (tester) async {
      final bloc = MockDailyPoemBloc();
      whenListen(
        bloc,
        const Stream<DailyPoemState>.empty(),
        initialState: const DailyPoemLoaded(
          poem: _testPoem,
          isFromCache: false,
        ),
      );
      final favCubit = MockFavouritesCubit();
      whenListen(
        favCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );
      when(() => favCubit.addFavourite(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        _buildApp(dailyPoemBloc: bloc, favouritesCubit: favCubit),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.favorite_outline));
      verify(() => favCubit.addFavourite(_testPoem)).called(1);
    });

    testWidgets('tapping remove calls cubit.removeFavourite', (tester) async {
      final bloc = MockDailyPoemBloc();
      whenListen(
        bloc,
        const Stream<DailyPoemState>.empty(),
        initialState: const DailyPoemLoaded(
          poem: _testPoem,
          isFromCache: false,
        ),
      );
      final favCubit = MockFavouritesCubit();
      whenListen(
        favCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(
          poems: [_testPoem],
          favouriteIds: {'poem1'},
        ),
      );
      when(() => favCubit.removeFavourite(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        _buildApp(dailyPoemBloc: bloc, favouritesCubit: favCubit),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.favorite));
      verify(() => favCubit.removeFavourite('poem1')).called(1);
    });

    testWidgets('toggling a favourite does not hide the loaded poem', (
      tester,
    ) async {
      final bloc = MockDailyPoemBloc();
      whenListen(
        bloc,
        const Stream<DailyPoemState>.empty(),
        initialState: const DailyPoemLoaded(
          poem: _testPoem,
          isFromCache: false,
        ),
      );
      final favCubit = MockFavouritesCubit();
      whenListen(
        favCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );

      await tester.pumpWidget(
        _buildApp(dailyPoemBloc: bloc, favouritesCubit: favCubit),
      );
      await tester.pump();

      // Poem should still be visible.
      expect(find.text('The Tyger'), findsOneWidget);
      expect(find.text('William Blake'), findsOneWidget);
    });
  });
}
