import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/poem.dart';
import 'package:daily_stanza/features/favourites/presentation/cubit/favourites_cubit.dart';
import 'package:daily_stanza/features/favourites/presentation/cubit/favourites_state.dart';
import 'package:daily_stanza/features/favourites/presentation/view/favourites_view.dart';

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

  Widget buildTestWidget() {
    return MaterialApp(
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
}
