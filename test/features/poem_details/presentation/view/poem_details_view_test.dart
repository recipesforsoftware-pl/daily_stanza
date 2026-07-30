import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:daily_stanza/core/theme/app_colors.dart';
import 'package:daily_stanza/core/theme/app_theme.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/poem.dart';
import 'package:daily_stanza/features/favourites/presentation/cubit/favourites_cubit.dart';
import 'package:daily_stanza/features/favourites/presentation/cubit/favourites_state.dart';
import 'package:daily_stanza/features/poem_details/presentation/cubit/poem_details_cubit.dart';
import 'package:daily_stanza/features/poem_details/presentation/cubit/poem_details_state.dart';
import 'package:daily_stanza/features/poem_details/presentation/view/poem_details_view.dart';
import 'package:daily_stanza/features/share_poem/domain/model/poem_share_result.dart';
import 'package:daily_stanza/features/share_poem/domain/service/poem_share_service.dart';
import 'package:daily_stanza/features/share_poem/presentation/cubit/poem_share_cubit.dart';

class MockPoemDetailsCubit extends MockBloc<PoemDetailsCubit, PoemDetailsState>
    implements PoemDetailsCubit {}

class MockFavouritesCubit extends MockBloc<FavouritesCubit, FavouritesState>
    implements FavouritesCubit {}

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
  required MockPoemDetailsCubit poemDetailsCubit,
  MockFavouritesCubit? favouritesCubit,
  PoemShareCubit? shareCubit,
  ThemeMode themeMode = ThemeMode.light,
}) {
  final favCubit = favouritesCubit ?? _createDefaultFavCubit();
  final shareCubitValue = shareCubit ?? _createDefaultShareCubit();
  return MaterialApp(
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: themeMode,
    home: MultiBlocProvider(
      providers: [
        BlocProvider<FavouritesCubit>.value(value: favCubit),
        BlocProvider<PoemDetailsCubit>.value(value: poemDetailsCubit),
        BlocProvider<PoemShareCubit>.value(value: shareCubitValue),
      ],
      child: const PoemDetailsView(),
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
  group('PoemDetailsView', () {
    testWidgets('loading indicator is displayed', (tester) async {
      final cubit = MockPoemDetailsCubit();
      whenListen(
        cubit,
        const Stream<PoemDetailsState>.empty(),
        initialState: const PoemDetailsLoading(),
      );

      await tester.pumpWidget(_buildApp(poemDetailsCubit: cubit));
      await tester.pump();

      expect(find.text('Loading poem\u2026'), findsOneWidget);
    });

    testWidgets('loaded title is displayed', (tester) async {
      final cubit = MockPoemDetailsCubit();
      whenListen(
        cubit,
        const Stream<PoemDetailsState>.empty(),
        initialState: const PoemDetailsLoaded(poem: _testPoem),
      );

      await tester.pumpWidget(_buildApp(poemDetailsCubit: cubit));
      await tester.pump();

      expect(find.text('The Tyger'), findsOneWidget);
    });

    testWidgets('loaded author is displayed', (tester) async {
      final cubit = MockPoemDetailsCubit();
      whenListen(
        cubit,
        const Stream<PoemDetailsState>.empty(),
        initialState: const PoemDetailsLoaded(poem: _testPoem),
      );

      await tester.pumpWidget(_buildApp(poemDetailsCubit: cubit));
      await tester.pump();

      expect(find.text('William Blake'), findsOneWidget);
    });

    testWidgets('full poem content is displayed', (tester) async {
      final cubit = MockPoemDetailsCubit();
      whenListen(
        cubit,
        const Stream<PoemDetailsState>.empty(),
        initialState: const PoemDetailsLoaded(poem: _testPoem),
      );

      await tester.pumpWidget(_buildApp(poemDetailsCubit: cubit));
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

    testWidgets('language and country chips are displayed', (tester) async {
      final cubit = MockPoemDetailsCubit();
      whenListen(
        cubit,
        const Stream<PoemDetailsState>.empty(),
        initialState: const PoemDetailsLoaded(poem: _testPoem),
      );

      await tester.pumpWidget(_buildApp(poemDetailsCubit: cubit));
      await tester.pump();

      expect(find.text('English'), findsOneWidget);
      expect(find.text('United Kingdom'), findsOneWidget);
    });

    testWidgets('source and rights text is displayed', (tester) async {
      final cubit = MockPoemDetailsCubit();
      whenListen(
        cubit,
        const Stream<PoemDetailsState>.empty(),
        initialState: const PoemDetailsLoaded(poem: _testPoem),
      );

      await tester.pumpWidget(_buildApp(poemDetailsCubit: cubit));
      await tester.pump();

      expect(find.textContaining('Songs of Experience'), findsOneWidget);
      expect(find.textContaining('public domain'), findsOneWidget);
    });

    testWidgets('missing state displays the expected message', (tester) async {
      final cubit = MockPoemDetailsCubit();
      whenListen(
        cubit,
        const Stream<PoemDetailsState>.empty(),
        initialState: const PoemDetailsMissing(),
      );

      await tester.pumpWidget(_buildApp(poemDetailsCubit: cubit));
      await tester.pump();

      expect(find.text('Poem not found'), findsOneWidget);
      expect(find.text('This poem is no longer available.'), findsOneWidget);
    });

    testWidgets('failure state displays the expected message', (tester) async {
      final cubit = MockPoemDetailsCubit();
      whenListen(
        cubit,
        const Stream<PoemDetailsState>.empty(),
        initialState: const PoemDetailsFailure(),
      );

      await tester.pumpWidget(_buildApp(poemDetailsCubit: cubit));
      await tester.pump();

      expect(find.text('Unable to load poem'), findsOneWidget);
      expect(
        find.text('Something went wrong. Please try again.'),
        findsOneWidget,
      );
    });

    testWidgets('failure state shows retry button', (tester) async {
      final cubit = MockPoemDetailsCubit();
      whenListen(
        cubit,
        const Stream<PoemDetailsState>.empty(),
        initialState: const PoemDetailsFailure(),
      );

      await tester.pumpWidget(_buildApp(poemDetailsCubit: cubit));
      await tester.pump();

      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('tapping retry calls retry on the cubit', (tester) async {
      final cubit = MockPoemDetailsCubit();
      whenListen(
        cubit,
        const Stream<PoemDetailsState>.empty(),
        initialState: const PoemDetailsFailure(),
      );
      when(() => cubit.retry()).thenAnswer((_) async {});

      await tester.pumpWidget(_buildApp(poemDetailsCubit: cubit));
      await tester.pump();

      await tester.tap(find.text('Try again'));
      verify(() => cubit.retry()).called(1);
    });

    testWidgets('favourite outline state shows unfilled heart', (tester) async {
      final cubit = MockPoemDetailsCubit();
      whenListen(
        cubit,
        const Stream<PoemDetailsState>.empty(),
        initialState: const PoemDetailsLoaded(poem: _testPoem),
      );
      final favCubit = MockFavouritesCubit();
      whenListen(
        favCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );

      await tester.pumpWidget(
        _buildApp(poemDetailsCubit: cubit, favouritesCubit: favCubit),
      );
      await tester.pump();

      expect(find.byIcon(Icons.favorite_outline), findsOneWidget);
    });

    testWidgets('favourite filled state shows filled heart', (tester) async {
      final cubit = MockPoemDetailsCubit();
      whenListen(
        cubit,
        const Stream<PoemDetailsState>.empty(),
        initialState: const PoemDetailsLoaded(poem: _testPoem),
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
        _buildApp(poemDetailsCubit: cubit, favouritesCubit: favCubit),
      );
      await tester.pump();

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('outline heart has "Add to favourites" semantic label', (
      tester,
    ) async {
      final cubit = MockPoemDetailsCubit();
      whenListen(
        cubit,
        const Stream<PoemDetailsState>.empty(),
        initialState: const PoemDetailsLoaded(poem: _testPoem),
      );
      final favCubit = MockFavouritesCubit();
      whenListen(
        favCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );

      await tester.pumpWidget(
        _buildApp(poemDetailsCubit: cubit, favouritesCubit: favCubit),
      );
      await tester.pump();

      expect(find.byTooltip('Add to favourites'), findsOneWidget);
    });

    testWidgets('filled heart has "Remove from favourites" semantic label', (
      tester,
    ) async {
      final cubit = MockPoemDetailsCubit();
      whenListen(
        cubit,
        const Stream<PoemDetailsState>.empty(),
        initialState: const PoemDetailsLoaded(poem: _testPoem),
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
        _buildApp(poemDetailsCubit: cubit, favouritesCubit: favCubit),
      );
      await tester.pump();

      expect(find.byTooltip('Remove from favourites'), findsOneWidget);
    });

    testWidgets('poem remains visible while favourite mutation is running', (
      tester,
    ) async {
      final cubit = MockPoemDetailsCubit();
      whenListen(
        cubit,
        const Stream<PoemDetailsState>.empty(),
        initialState: const PoemDetailsLoaded(poem: _testPoem),
      );
      final favCubit = MockFavouritesCubit();
      whenListen(
        favCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(
          poems: [],
          favouriteIds: {'poem1'},
          updatingPoemIds: {'poem1'},
        ),
      );

      await tester.pumpWidget(
        _buildApp(poemDetailsCubit: cubit, favouritesCubit: favCubit),
      );
      await tester.pump();

      expect(find.text('The Tyger'), findsOneWidget);
      expect(find.text('William Blake'), findsOneWidget);
    });

    testWidgets('long poem scrolls without overflow', (tester) async {
      final cubit = MockPoemDetailsCubit();
      whenListen(
        cubit,
        const Stream<PoemDetailsState>.empty(),
        initialState: const PoemDetailsLoaded(poem: _longPoem),
      );
      final favCubit = MockFavouritesCubit();
      whenListen(
        favCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );

      await tester.pumpWidget(
        _buildApp(poemDetailsCubit: cubit, favouritesCubit: favCubit),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('small-screen layout does not overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final cubit = MockPoemDetailsCubit();
      whenListen(
        cubit,
        const Stream<PoemDetailsState>.empty(),
        initialState: const PoemDetailsLoaded(poem: _testPoem),
      );
      final favCubit = MockFavouritesCubit();
      whenListen(
        favCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );

      await tester.pumpWidget(
        _buildApp(poemDetailsCubit: cubit, favouritesCubit: favCubit),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('Stanzi is absent from loaded state', (tester) async {
      final cubit = MockPoemDetailsCubit();
      whenListen(
        cubit,
        const Stream<PoemDetailsState>.empty(),
        initialState: const PoemDetailsLoaded(poem: _testPoem),
      );
      final favCubit = MockFavouritesCubit();
      whenListen(
        favCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );

      await tester.pumpWidget(
        _buildApp(poemDetailsCubit: cubit, favouritesCubit: favCubit),
      );
      await tester.pump();

      expect(find.byType(Image), findsNothing);
    });

    // --- Dark-theme contrast tests ---

    testWidgets('dark theme: title uses readable on-surface colour', (
      tester,
    ) async {
      final cubit = MockPoemDetailsCubit();
      whenListen(
        cubit,
        const Stream<PoemDetailsState>.empty(),
        initialState: const PoemDetailsLoaded(poem: _testPoem),
      );
      final favCubit = MockFavouritesCubit();
      whenListen(
        favCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );

      await tester.pumpWidget(
        _buildApp(
          poemDetailsCubit: cubit,
          favouritesCubit: favCubit,
          themeMode: ThemeMode.dark,
        ),
      );
      await tester.pump();

      final titleText = tester.widget<Text>(find.text('The Tyger'));
      expect(titleText.style?.color, equals(AppColors.darkFg));
    });

    testWidgets('dark theme: author uses muted colour', (tester) async {
      final cubit = MockPoemDetailsCubit();
      whenListen(
        cubit,
        const Stream<PoemDetailsState>.empty(),
        initialState: const PoemDetailsLoaded(poem: _testPoem),
      );
      final favCubit = MockFavouritesCubit();
      whenListen(
        favCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );

      await tester.pumpWidget(
        _buildApp(
          poemDetailsCubit: cubit,
          favouritesCubit: favCubit,
          themeMode: ThemeMode.dark,
        ),
      );
      await tester.pump();

      final authorText = tester.widget<Text>(find.text('William Blake'));
      expect(authorText.style?.color, equals(AppColors.darkMuted));
    });

    testWidgets('dark theme: poem body uses readable foreground', (
      tester,
    ) async {
      final cubit = MockPoemDetailsCubit();
      whenListen(
        cubit,
        const Stream<PoemDetailsState>.empty(),
        initialState: const PoemDetailsLoaded(poem: _testPoem),
      );
      final favCubit = MockFavouritesCubit();
      whenListen(
        favCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );

      await tester.pumpWidget(
        _buildApp(
          poemDetailsCubit: cubit,
          favouritesCubit: favCubit,
          themeMode: ThemeMode.dark,
        ),
      );
      await tester.pump();

      final bodyWidget = tester.widget<EditableText>(
        find.textContaining('Tyger Tyger, burning bright'),
      );
      expect(bodyWidget.style.color, equals(AppColors.darkFg));
    });

    testWidgets('dark theme: chip text uses readable colour', (tester) async {
      final cubit = MockPoemDetailsCubit();
      whenListen(
        cubit,
        const Stream<PoemDetailsState>.empty(),
        initialState: const PoemDetailsLoaded(poem: _testPoem),
      );
      final favCubit = MockFavouritesCubit();
      whenListen(
        favCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );

      await tester.pumpWidget(
        _buildApp(
          poemDetailsCubit: cubit,
          favouritesCubit: favCubit,
          themeMode: ThemeMode.dark,
        ),
      );
      await tester.pump();

      final chipText = tester.widget<Text>(find.text('English'));
      expect(chipText.style?.color, equals(AppColors.darkMuted));
    });

    testWidgets('dark theme: favourite icon uses theme-aware colour', (
      tester,
    ) async {
      final cubit = MockPoemDetailsCubit();
      whenListen(
        cubit,
        const Stream<PoemDetailsState>.empty(),
        initialState: const PoemDetailsLoaded(poem: _testPoem),
      );
      final favCubit = MockFavouritesCubit();
      whenListen(
        favCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );

      await tester.pumpWidget(
        _buildApp(
          poemDetailsCubit: cubit,
          favouritesCubit: favCubit,
          themeMode: ThemeMode.dark,
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.favorite_outline), findsOneWidget);
    });

    // --- AppBar title contrast tests ---

    testWidgets('light theme: AppBar title "Poem" renders', (tester) async {
      final cubit = MockPoemDetailsCubit();
      whenListen(
        cubit,
        const Stream<PoemDetailsState>.empty(),
        initialState: const PoemDetailsLoading(),
      );

      await tester.pumpWidget(_buildApp(poemDetailsCubit: cubit));
      await tester.pump();

      expect(find.text('Poem'), findsOneWidget);
    });

    testWidgets('light theme: AppBar title uses readable foreground', (
      tester,
    ) async {
      final cubit = MockPoemDetailsCubit();
      whenListen(
        cubit,
        const Stream<PoemDetailsState>.empty(),
        initialState: const PoemDetailsLoading(),
      );

      await tester.pumpWidget(_buildApp(poemDetailsCubit: cubit));
      await tester.pump();

      // Title color may be set directly on the Text widget or inherited
      // from the AppBar's DefaultTextStyle. Check either.
      final titleText = tester.widget<Text>(find.text('Poem'));
      if (titleText.style?.color != null) {
        expect(titleText.style?.color, equals(AppColors.lightFg));
      } else {
        final defaultTextStyle = tester.widget<DefaultTextStyle>(
          find
              .ancestor(
                of: find.text('Poem'),
                matching: find.byType(DefaultTextStyle),
              )
              .first,
        );
        expect(defaultTextStyle.style.color, equals(AppColors.lightFg));
      }
    });

    testWidgets('dark theme: AppBar title "Poem" renders', (tester) async {
      final cubit = MockPoemDetailsCubit();
      whenListen(
        cubit,
        const Stream<PoemDetailsState>.empty(),
        initialState: const PoemDetailsLoading(),
      );

      await tester.pumpWidget(
        _buildApp(poemDetailsCubit: cubit, themeMode: ThemeMode.dark),
      );
      await tester.pump();

      expect(find.text('Poem'), findsOneWidget);
    });

    testWidgets('light theme: AppBar title is not white', (tester) async {
      final cubit = MockPoemDetailsCubit();
      whenListen(
        cubit,
        const Stream<PoemDetailsState>.empty(),
        initialState: const PoemDetailsLoading(),
      );

      await tester.pumpWidget(_buildApp(poemDetailsCubit: cubit));
      await tester.pump();

      final titleText = tester.widget<Text>(find.text('Poem'));
      expect(titleText.style?.color, isNot(equals(Colors.white)));
    });

    testWidgets('dark theme: AppBar title is not dark', (tester) async {
      final cubit = MockPoemDetailsCubit();
      whenListen(
        cubit,
        const Stream<PoemDetailsState>.empty(),
        initialState: const PoemDetailsLoading(),
      );

      await tester.pumpWidget(
        _buildApp(poemDetailsCubit: cubit, themeMode: ThemeMode.dark),
      );
      await tester.pump();

      final titleText = tester.widget<Text>(find.text('Poem'));
      expect(titleText.style?.color, isNot(equals(AppColors.darkBg)));
    });

    // --- Status view contrast tests ---

    testWidgets('dark theme: loading title uses onSurface colour', (
      tester,
    ) async {
      final cubit = MockPoemDetailsCubit();
      whenListen(
        cubit,
        const Stream<PoemDetailsState>.empty(),
        initialState: const PoemDetailsLoading(),
      );

      await tester.pumpWidget(
        _buildApp(poemDetailsCubit: cubit, themeMode: ThemeMode.dark),
      );
      await tester.pump();

      final titleText = tester.widget<Text>(find.text('Loading poem\u2026'));
      expect(titleText.style?.color, equals(AppColors.darkFg));
    });

    testWidgets('dark theme: loading message uses onSurfaceVariant colour', (
      tester,
    ) async {
      final cubit = MockPoemDetailsCubit();
      whenListen(
        cubit,
        const Stream<PoemDetailsState>.empty(),
        initialState: const PoemDetailsLoading(),
      );

      await tester.pumpWidget(
        _buildApp(poemDetailsCubit: cubit, themeMode: ThemeMode.dark),
      );
      await tester.pump();

      final msgText = tester.widget<Text>(
        find.text('Taking a calm moment to prepare your reading.'),
      );
      expect(msgText.style?.color, equals(AppColors.darkMuted));
    });

    testWidgets('light theme: loading title is not white', (tester) async {
      final cubit = MockPoemDetailsCubit();
      whenListen(
        cubit,
        const Stream<PoemDetailsState>.empty(),
        initialState: const PoemDetailsLoading(),
      );

      await tester.pumpWidget(_buildApp(poemDetailsCubit: cubit));
      await tester.pump();

      final titleText = tester.widget<Text>(find.text('Loading poem\u2026'));
      expect(titleText.style?.color, isNot(equals(Colors.white)));
    });

    testWidgets('light theme: loading message is not white', (tester) async {
      final cubit = MockPoemDetailsCubit();
      whenListen(
        cubit,
        const Stream<PoemDetailsState>.empty(),
        initialState: const PoemDetailsLoading(),
      );

      await tester.pumpWidget(_buildApp(poemDetailsCubit: cubit));
      await tester.pump();

      final msgText = tester.widget<Text>(
        find.text('Taking a calm moment to prepare your reading.'),
      );
      expect(msgText.style?.color, isNot(equals(Colors.white)));
    });

    testWidgets('failure retry button is enabled when callback provided', (
      tester,
    ) async {
      final cubit = MockPoemDetailsCubit();
      whenListen(
        cubit,
        const Stream<PoemDetailsState>.empty(),
        initialState: const PoemDetailsFailure(),
      );
      when(() => cubit.retry()).thenAnswer((_) async {});

      await tester.pumpWidget(_buildApp(poemDetailsCubit: cubit));
      await tester.pump();

      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Try again'),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('light theme: Share icon is visible', (tester) async {
      final cubit = MockPoemDetailsCubit();
      whenListen(
        cubit,
        const Stream<PoemDetailsState>.empty(),
        initialState: const PoemDetailsLoaded(poem: _testPoem),
      );
      final favCubit = MockFavouritesCubit();
      whenListen(
        favCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );

      await tester.pumpWidget(
        _buildApp(poemDetailsCubit: cubit, favouritesCubit: favCubit),
      );
      await tester.pump();

      expect(find.byIcon(Icons.share), findsOneWidget);
    });

    testWidgets('dark theme: Share icon is visible', (tester) async {
      final cubit = MockPoemDetailsCubit();
      whenListen(
        cubit,
        const Stream<PoemDetailsState>.empty(),
        initialState: const PoemDetailsLoaded(poem: _testPoem),
      );
      final favCubit = MockFavouritesCubit();
      whenListen(
        favCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );

      await tester.pumpWidget(
        _buildApp(
          poemDetailsCubit: cubit,
          favouritesCubit: favCubit,
          themeMode: ThemeMode.dark,
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.share), findsOneWidget);
    });

    testWidgets('large text scale does not cause AppBar overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      tester.view.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.platformDispatcher.clearTextScaleFactorTestValue();
      });

      final cubit = MockPoemDetailsCubit();
      whenListen(
        cubit,
        const Stream<PoemDetailsState>.empty(),
        initialState: const PoemDetailsLoading(),
      );

      await tester.pumpWidget(_buildApp(poemDetailsCubit: cubit));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('small viewport does not cause layout exceptions', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final cubit = MockPoemDetailsCubit();
      whenListen(
        cubit,
        const Stream<PoemDetailsState>.empty(),
        initialState: const PoemDetailsLoading(),
      );

      await tester.pumpWidget(_buildApp(poemDetailsCubit: cubit));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
