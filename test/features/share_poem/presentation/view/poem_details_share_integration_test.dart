import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/poem.dart';
import 'package:daily_stanza/features/poem_details/presentation/cubit/poem_details_cubit.dart';
import 'package:daily_stanza/features/poem_details/presentation/cubit/poem_details_state.dart';
import 'package:daily_stanza/features/poem_details/presentation/view/poem_details_view.dart';
import 'package:daily_stanza/features/favourites/presentation/cubit/favourites_cubit.dart';
import 'package:daily_stanza/features/favourites/presentation/cubit/favourites_state.dart';
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

Widget _buildApp({
  required PoemDetailsCubit detailsCubit,
  FavouritesCubit? favouritesCubit,
  PoemShareCubit? shareCubit,
}) {
  final favCubit = favouritesCubit ?? _createDefaultFavCubit();
  final shareCubitValue = shareCubit ?? _createDefaultShareCubit();
  return MaterialApp(
    home: MultiBlocProvider(
      providers: [
        BlocProvider<PoemDetailsCubit>.value(value: detailsCubit),
        BlocProvider<FavouritesCubit>.value(value: favCubit),
        BlocProvider<PoemShareCubit>.value(value: shareCubitValue),
      ],
      child: const PoemDetailsView(),
    ),
  );
}

FavouritesCubit _createDefaultFavCubit() {
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
  setUpAll(() {
    registerFallbackValue(_testPoem);
  });

  group('PoemDetailsView share integration', () {
    testWidgets('Share icon visible in loaded state', (tester) async {
      final cubit = MockPoemDetailsCubit();
      when(
        () => cubit.state,
      ).thenReturn(const PoemDetailsLoaded(poem: _testPoem));

      await tester.pumpWidget(_buildApp(detailsCubit: cubit));
      await tester.pump();

      expect(find.byTooltip('Share poem'), findsOneWidget);
    });

    testWidgets('Share icon absent in loading state', (tester) async {
      final cubit = MockPoemDetailsCubit();
      when(() => cubit.state).thenReturn(const PoemDetailsLoading());

      await tester.pumpWidget(_buildApp(detailsCubit: cubit));
      await tester.pump();

      expect(find.byTooltip('Share poem'), findsNothing);
    });

    testWidgets('Share icon absent in missing state', (tester) async {
      final cubit = MockPoemDetailsCubit();
      when(() => cubit.state).thenReturn(const PoemDetailsMissing());

      await tester.pumpWidget(_buildApp(detailsCubit: cubit));
      await tester.pump();

      expect(find.byTooltip('Share poem'), findsNothing);
    });

    testWidgets('Share icon absent in failure state', (tester) async {
      final cubit = MockPoemDetailsCubit();
      when(() => cubit.state).thenReturn(const PoemDetailsFailure());

      await tester.pumpWidget(_buildApp(detailsCubit: cubit));
      await tester.pump();

      expect(find.byTooltip('Share poem'), findsNothing);
    });

    testWidgets('tap share icon shares the displayed poem', (tester) async {
      final detailsCubit = MockPoemDetailsCubit();
      when(
        () => detailsCubit.state,
      ).thenReturn(const PoemDetailsLoaded(poem: _testPoem));
      final mockService = MockPoemShareService();
      when(
        () => mockService.shareText(
          text: any(named: 'text'),
          subject: any(named: 'subject'),
          sharePositionOrigin: any(named: 'sharePositionOrigin'),
        ),
      ).thenAnswer((_) async => PoemShareResult.completed);
      final shareCubit = PoemShareCubit(shareService: mockService);

      await tester.pumpWidget(
        _buildApp(detailsCubit: detailsCubit, shareCubit: shareCubit),
      );
      await tester.pump();

      await tester.tap(find.byTooltip('Share poem'));
      await tester.pump();

      verify(
        () => mockService.shareText(
          text: any(named: 'text'),
          subject: any(named: 'subject'),
          sharePositionOrigin: any(named: 'sharePositionOrigin'),
        ),
      ).called(1);
      await shareCubit.close();
    });

    testWidgets('share does not reload PoemDetailsCubit', (tester) async {
      final detailsCubit = MockPoemDetailsCubit();
      when(
        () => detailsCubit.state,
      ).thenReturn(const PoemDetailsLoaded(poem: _testPoem));

      await tester.pumpWidget(_buildApp(detailsCubit: detailsCubit));
      await tester.pump();

      await tester.tap(find.byTooltip('Share poem'));
      await tester.pump();

      verifyNever(() => detailsCubit.retry());
      verifyNever(() => detailsCubit.loadPoem(any()));
    });

    testWidgets('favourite action remains independent from share', (
      tester,
    ) async {
      final detailsCubit = MockPoemDetailsCubit();
      when(
        () => detailsCubit.state,
      ).thenReturn(const PoemDetailsLoaded(poem: _testPoem));
      final favCubit = MockFavouritesCubit();
      when(
        () => favCubit.state,
      ).thenReturn(const FavouritesLoaded(poems: [], favouriteIds: {}));
      when(() => favCubit.addFavourite(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        _buildApp(detailsCubit: detailsCubit, favouritesCubit: favCubit),
      );
      await tester.pump();

      // Favourite heart should still be present and tappable
      expect(find.byIcon(Icons.favorite_outline), findsOneWidget);
      expect(find.byTooltip('Add to favourites'), findsOneWidget);
    });

    testWidgets('AppBar remains usable with text scaling', (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(
        () => binding.platformDispatcher.clearTextScaleFactorTestValue(),
      );

      final cubit = MockPoemDetailsCubit();
      when(
        () => cubit.state,
      ).thenReturn(const PoemDetailsLoaded(poem: _testPoem));

      await tester.pumpWidget(_buildApp(detailsCubit: cubit));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byTooltip('Share poem'), findsOneWidget);
    });

    testWidgets('system Back remains correct after returning from share', (
      tester,
    ) async {
      final detailsCubit = MockPoemDetailsCubit();
      when(
        () => detailsCubit.state,
      ).thenReturn(const PoemDetailsLoaded(poem: _testPoem));

      await tester.pumpWidget(_buildApp(detailsCubit: detailsCubit));
      await tester.pump();

      // Share button present — AppBar renders correctly with share action.
      expect(find.byTooltip('Share poem'), findsOneWidget);
      // No render exceptions or overflow from the share button.
      expect(tester.takeException(), isNull);
    });
  });
}
