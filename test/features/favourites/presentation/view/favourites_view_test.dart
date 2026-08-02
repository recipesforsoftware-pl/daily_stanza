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
import 'package:daily_stanza/features/favourites/presentation/view/favourites_view.dart';
import 'package:daily_stanza/features/favourites/presentation/widgets/favourite_poem_card.dart';

class MockFavouritesCubit extends MockBloc<FavouritesCubit, FavouritesState>
    implements FavouritesCubit {}

const _poemA = Poem(
  id: 'a',
  title: 'Poem A',
  author: 'Author A',
  languageCode: 'en',
  countryCode: 'US',
  content: 'Content of poem A. Short excerpt.',
  sourceName: 'Source',
  sourceUrl: 'https://example.com/a',
  rightsStatus: 'public_domain',
);

const _longPoem = Poem(
  id: 'long',
  title: 'A Very Long Poem Title That Might Wrap',
  author: 'Prolific Author',
  languageCode: 'en',
  countryCode: 'GB',
  content:
      'This is a very long content that should span multiple lines '
      'and test whether the card layout handles overflow correctly. '
      'Lorem ipsum dolor sit amet consectetur adipiscing elit.',
  sourceName: 'Collection',
  sourceUrl: 'https://example.com/long',
  rightsStatus: 'public_domain',
);

const _poemB = Poem(
  id: 'b',
  title: 'Poem B',
  author: 'Author B',
  languageCode: 'pl',
  countryCode: 'PL',
  content: 'Content of poem B. Another excerpt.',
  sourceName: 'Source',
  sourceUrl: 'https://example.com/b',
  rightsStatus: 'public_domain',
);

void main() {
  late MockFavouritesCubit mockCubit;

  setUp(() {
    mockCubit = MockFavouritesCubit();
  });

  Widget buildTestWidget({ThemeMode themeMode = ThemeMode.light}) {
    return MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: BlocProvider<FavouritesCubit>.value(
        value: mockCubit,
        child: const FavouritesView(),
      ),
    );
  }

  group('FavouritesView', () {
    testWidgets('loading state renders progress indicator', (tester) async {
      whenListen(
        mockCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoading(),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('empty state shows Stanzi', (tester) async {
      whenListen(
        mockCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('empty state shows the required title and description', (
      tester,
    ) async {
      whenListen(
        mockCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('No favourite poems yet'), findsOneWidget);
      expect(
        find.text('Save a poem from Today and it will appear here.'),
        findsOneWidget,
      );
    });

    testWidgets('loaded state shows poem titles and authors', (tester) async {
      whenListen(
        mockCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(
          poems: [_poemA, _poemB],
          favouriteIds: {'a', 'b'},
        ),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Poem A'), findsOneWidget);
      expect(find.text('Poem B'), findsOneWidget);
      expect(find.text('Author A'), findsOneWidget);
      expect(find.text('Author B'), findsOneWidget);
    });

    testWidgets('loaded cards show excerpts', (tester) async {
      whenListen(
        mockCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(
          poems: [_poemA],
          favouriteIds: {'a'},
        ),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(
        find.textContaining('Content of poem A. Short excerpt.'),
        findsOneWidget,
      );
    });

    testWidgets('remove action has an accessible label', (tester) async {
      whenListen(
        mockCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(
          poems: [_poemA],
          favouriteIds: {'a'},
        ),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      expect(find.byTooltip('Remove from favourites'), findsOneWidget);
    });

    testWidgets('removing an item calls cubit.removeFavourite', (tester) async {
      whenListen(
        mockCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(
          poems: [_poemA],
          favouriteIds: {'a'},
        ),
      );
      when(() => mockCubit.removeFavourite(any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.delete_outline));
      verify(() => mockCubit.removeFavourite('a')).called(1);
    });

    testWidgets('failure state shows retry', (tester) async {
      whenListen(
        mockCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesFailure(),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Unable to load favourites'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('tapping retry calls loadFavourites', (tester) async {
      whenListen(
        mockCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesFailure(),
      );
      when(() => mockCubit.loadFavourites()).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      await tester.tap(find.text('Try again'));
      verify(() => mockCubit.loadFavourites()).called(1);
    });

    testWidgets('long poem content does not overflow', (tester) async {
      const longPoem = Poem(
        id: 'long',
        title: 'A Very Long Poem Title That Might Wrap',
        author: 'Prolific Author',
        languageCode: 'en',
        countryCode: 'GB',
        content:
            'This is a very long content that should span multiple lines '
            'and test whether the card layout handles overflow correctly. '
            'Lorem ipsum dolor sit amet consectetur adipiscing elit.',
        sourceName: 'Collection',
        sourceUrl: 'https://example.com/long',
        rightsStatus: 'public_domain',
      );

      whenListen(
        mockCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(
          poems: [longPoem],
          favouriteIds: {'long'},
        ),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('small-screen layout does not overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      whenListen(
        mockCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(
          poems: [_poemA, _poemB],
          favouriteIds: {'a', 'b'},
        ),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  // --- Dark-theme contrast tests ---

  testWidgets(
    'dark theme: favourites loaded state renders with readable colours',
    (tester) async {
      whenListen(
        mockCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(
          poems: [_poemA],
          favouriteIds: {'a'},
        ),
      );

      await tester.pumpWidget(buildTestWidget(themeMode: ThemeMode.dark));
      await tester.pump();

      expect(find.text('Poem A'), findsOneWidget);
      expect(find.text('Author A'), findsOneWidget);
    },
  );

  testWidgets('dark theme: poem title uses a readable on-surface colour', (
    tester,
  ) async {
    whenListen(
      mockCubit,
      const Stream<FavouritesState>.empty(),
      initialState: const FavouritesLoaded(
        poems: [_poemA],
        favouriteIds: {'a'},
      ),
    );

    await tester.pumpWidget(buildTestWidget(themeMode: ThemeMode.dark));
    await tester.pump();

    final titleText = tester.widget<Text>(find.text('Poem A'));
    expect(titleText.style?.color, equals(AppColors.darkFg));
  });

  testWidgets('dark theme: author uses readable secondary foreground', (
    tester,
  ) async {
    whenListen(
      mockCubit,
      const Stream<FavouritesState>.empty(),
      initialState: const FavouritesLoaded(
        poems: [_poemA],
        favouriteIds: {'a'},
      ),
    );

    await tester.pumpWidget(buildTestWidget(themeMode: ThemeMode.dark));
    await tester.pump();

    final authorText = tester.widget<Text>(find.text('Author A'));
    expect(authorText.style?.color, equals(AppColors.darkMuted));
  });

  testWidgets('dark theme: poem preview uses readable secondary foreground', (
    tester,
  ) async {
    whenListen(
      mockCubit,
      const Stream<FavouritesState>.empty(),
      initialState: const FavouritesLoaded(
        poems: [_poemA],
        favouriteIds: {'a'},
      ),
    );

    await tester.pumpWidget(buildTestWidget(themeMode: ThemeMode.dark));
    await tester.pump();

    final previewText = tester.widget<Text>(
      find.textContaining('Content of poem A.'),
    );
    expect(previewText.style?.color, equals(AppColors.darkMuted));
  });

  testWidgets('dark theme: remove icon is visible', (tester) async {
    whenListen(
      mockCubit,
      const Stream<FavouritesState>.empty(),
      initialState: const FavouritesLoaded(
        poems: [_poemA],
        favouriteIds: {'a'},
      ),
    );

    await tester.pumpWidget(buildTestWidget(themeMode: ThemeMode.dark));
    await tester.pump();

    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });

  testWidgets('dark theme: card surface and border resolve from colorScheme', (
    tester,
  ) async {
    whenListen(
      mockCubit,
      const Stream<FavouritesState>.empty(),
      initialState: const FavouritesLoaded(
        poems: [_poemA],
        favouriteIds: {'a'},
      ),
    );

    await tester.pumpWidget(buildTestWidget(themeMode: ThemeMode.dark));
    await tester.pump();

    expect(find.byType(Card), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dark theme: chips remain readable', (tester) async {
    whenListen(
      mockCubit,
      const Stream<FavouritesState>.empty(),
      initialState: const FavouritesLoaded(
        poems: [_poemA],
        favouriteIds: {'a'},
      ),
    );

    await tester.pumpWidget(buildTestWidget(themeMode: ThemeMode.dark));
    await tester.pump();

    final chipText = tester.widget<Text>(find.text('English'));
    expect(chipText.style?.color, equals(AppColors.darkMuted));
  });

  testWidgets('light theme: no forced white foreground on text', (
    tester,
  ) async {
    whenListen(
      mockCubit,
      const Stream<FavouritesState>.empty(),
      initialState: const FavouritesLoaded(
        poems: [_poemA],
        favouriteIds: {'a'},
      ),
    );

    await tester.pumpWidget(buildTestWidget());
    await tester.pump();

    final titleText = tester.widget<Text>(find.text('Poem A'));
    expect(titleText.style?.color, isNot(equals(Colors.white)));
    final authorText = tester.widget<Text>(find.text('Author A'));
    expect(authorText.style?.color, isNot(equals(Colors.white)));
  });

  testWidgets('dark theme: card passes onOpen callback', (tester) async {
    whenListen(
      mockCubit,
      const Stream<FavouritesState>.empty(),
      initialState: const FavouritesLoaded(
        poems: [_poemA],
        favouriteIds: {'a'},
      ),
    );

    await tester.pumpWidget(buildTestWidget(themeMode: ThemeMode.dark));
    await tester.pump();

    final cardWidget = tester.widget<FavouritePoemCard>(
      find.byType(FavouritePoemCard),
    );
    expect(cardWidget.onOpen, isNotNull);
  });

  testWidgets('dark theme: tapping remove does not open poem details', (
    tester,
  ) async {
    whenListen(
      mockCubit,
      const Stream<FavouritesState>.empty(),
      initialState: const FavouritesLoaded(
        poems: [_poemA],
        favouriteIds: {'a'},
      ),
    );
    when(() => mockCubit.removeFavourite(any())).thenAnswer((_) async {});

    await tester.pumpWidget(buildTestWidget(themeMode: ThemeMode.dark));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.delete_outline));
    verify(() => mockCubit.removeFavourite('a')).called(1);
  });

  testWidgets('dark theme: tapping remove still removes the poem', (
    tester,
  ) async {
    whenListen(
      mockCubit,
      const Stream<FavouritesState>.empty(),
      initialState: const FavouritesLoaded(
        poems: [_poemA],
        favouriteIds: {'a'},
      ),
    );
    when(() => mockCubit.removeFavourite(any())).thenAnswer((_) async {});

    await tester.pumpWidget(buildTestWidget(themeMode: ThemeMode.dark));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.delete_outline));
    verify(() => mockCubit.removeFavourite('a')).called(1);
  });

  testWidgets('dark theme: empty state remains readable', (tester) async {
    whenListen(
      mockCubit,
      const Stream<FavouritesState>.empty(),
      initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
    );

    await tester.pumpWidget(buildTestWidget(themeMode: ThemeMode.dark));
    await tester.pump();

    expect(find.text('No favourite poems yet'), findsOneWidget);
    expect(
      find.text('Save a poem from Today and it will appear here.'),
      findsOneWidget,
    );
  });

  testWidgets('dark theme: long preview text does not overflow', (
    tester,
  ) async {
    whenListen(
      mockCubit,
      const Stream<FavouritesState>.empty(),
      initialState: const FavouritesLoaded(
        poems: [_longPoem],
        favouriteIds: {'long'},
      ),
    );

    await tester.pumpWidget(buildTestWidget(themeMode: ThemeMode.dark));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('dark theme: small viewport rendering has no layout exception', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    whenListen(
      mockCubit,
      const Stream<FavouritesState>.empty(),
      initialState: const FavouritesLoaded(
        poems: [_poemA, _poemB],
        favouriteIds: {'a', 'b'},
      ),
    );

    await tester.pumpWidget(buildTestWidget(themeMode: ThemeMode.dark));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('dark theme: failure state title uses readable foreground', (
    tester,
  ) async {
    whenListen(
      mockCubit,
      const Stream<FavouritesState>.empty(),
      initialState: const FavouritesFailure(),
    );

    await tester.pumpWidget(buildTestWidget(themeMode: ThemeMode.dark));
    await tester.pump();

    expect(find.text('Unable to load favourites'), findsOneWidget);
    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
  });

  testWidgets('dark theme: error retry action is visible', (tester) async {
    whenListen(
      mockCubit,
      const Stream<FavouritesState>.empty(),
      initialState: const FavouritesFailure(),
    );

    await tester.pumpWidget(buildTestWidget(themeMode: ThemeMode.dark));
    await tester.pump();

    expect(find.text('Try again'), findsOneWidget);
  });

  // --- AppBar title contrast tests ---

  testWidgets('light theme: AppBar title "Favourites" renders', (tester) async {
    whenListen(
      mockCubit,
      const Stream<FavouritesState>.empty(),
      initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
    );

    await tester.pumpWidget(buildTestWidget());
    await tester.pump();

    expect(find.text('Favourites'), findsOneWidget);
  });

  testWidgets('light theme: AppBar title uses readable foreground', (
    tester,
  ) async {
    whenListen(
      mockCubit,
      const Stream<FavouritesState>.empty(),
      initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
    );

    await tester.pumpWidget(buildTestWidget());
    await tester.pump();

    // Title color may be set directly on the Text widget or inherited
    // from the AppBar's DefaultTextStyle. Check either.
    final titleText = tester.widget<Text>(find.text('Favourites'));
    if (titleText.style?.color != null) {
      expect(titleText.style?.color, equals(AppColors.lightFg));
    } else {
      final defaultTextStyle = tester.widget<DefaultTextStyle>(
        find
            .ancestor(
              of: find.text('Favourites'),
              matching: find.byType(DefaultTextStyle),
            )
            .first,
      );
      expect(defaultTextStyle.style.color, equals(AppColors.lightFg));
    }
  });

  testWidgets('dark theme: AppBar title "Favourites" renders', (tester) async {
    whenListen(
      mockCubit,
      const Stream<FavouritesState>.empty(),
      initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
    );

    await tester.pumpWidget(buildTestWidget(themeMode: ThemeMode.dark));
    await tester.pump();

    expect(find.text('Favourites'), findsOneWidget);
  });

  testWidgets('light theme: AppBar title is not white', (tester) async {
    whenListen(
      mockCubit,
      const Stream<FavouritesState>.empty(),
      initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
    );

    await tester.pumpWidget(buildTestWidget());
    await tester.pump();

    final titleText = tester.widget<Text>(find.text('Favourites'));
    expect(titleText.style?.color, isNot(equals(Colors.white)));
  });

  testWidgets('dark theme: AppBar title is not dark', (tester) async {
    whenListen(
      mockCubit,
      const Stream<FavouritesState>.empty(),
      initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
    );

    await tester.pumpWidget(buildTestWidget(themeMode: ThemeMode.dark));
    await tester.pump();

    final titleText = tester.widget<Text>(find.text('Favourites'));
    expect(titleText.style?.color, isNot(equals(AppColors.darkBg)));
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

    whenListen(
      mockCubit,
      const Stream<FavouritesState>.empty(),
      initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
    );

    await tester.pumpWidget(buildTestWidget());
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('small viewport does not cause layout exceptions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    whenListen(
      mockCubit,
      const Stream<FavouritesState>.empty(),
      initialState: const FavouritesLoaded(
        poems: [_poemA],
        favouriteIds: {'a'},
      ),
    );

    await tester.pumpWidget(buildTestWidget());
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
