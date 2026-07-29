import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
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
  });

  group('TodayView share integration', () {
    testWidgets('Share button visible in loaded state', (tester) async {
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

      expect(find.text('Share poem'), findsOneWidget);
    });

    testWidgets('Share button absent in loading state', (tester) async {
      final bloc = MockDailyPoemBloc();
      whenListen(
        bloc,
        const Stream<DailyPoemState>.empty(),
        initialState: const DailyPoemLoading(),
      );

      await tester.pumpWidget(_buildApp(dailyPoemBloc: bloc));
      await tester.pump();

      expect(find.text('Share poem'), findsNothing);
    });

    testWidgets('Share button absent in missing state', (tester) async {
      final bloc = MockDailyPoemBloc();
      whenListen(
        bloc,
        const Stream<DailyPoemState>.empty(),
        initialState: const DailyPoemMissing(),
      );

      await tester.pumpWidget(_buildApp(dailyPoemBloc: bloc));
      await tester.pump();

      expect(find.text('Share poem'), findsNothing);
    });

    testWidgets('Share button absent in failure state', (tester) async {
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

      expect(find.text('Share poem'), findsNothing);
    });

    testWidgets('tap share button shares the loaded poem', (tester) async {
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
        _buildApp(
          dailyPoemBloc: bloc,
          favouritesCubit: favCubit,
          shareCubit: shareCubit,
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Share poem'));
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

    testWidgets('share does not dispatch DailyPoemRequested', (tester) async {
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

      await tester.tap(find.text('Share poem'));
      await tester.pump();

      // initState calls add() once; the share action must not add another.
      verify(() => bloc.add(any())).called(1);
    });

    testWidgets('share does not toggle favourite', (tester) async {
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

      await tester.tap(find.text('Share poem'));
      await tester.pump();

      verifyNever(() => favCubit.addFavourite(any()));
      verifyNever(() => favCubit.removeFavourite(any()));
    });

    testWidgets('rapid taps create one share request', (tester) async {
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
      final shareCompleter = Completer<PoemShareResult>();
      final mockService = MockPoemShareService();
      when(
        () => mockService.shareText(
          text: any(named: 'text'),
          subject: any(named: 'subject'),
          sharePositionOrigin: any(named: 'sharePositionOrigin'),
        ),
      ).thenAnswer((_) => shareCompleter.future);
      final shareCubit = PoemShareCubit(shareService: mockService);

      await tester.pumpWidget(
        _buildApp(
          dailyPoemBloc: bloc,
          favouritesCubit: favCubit,
          shareCubit: shareCubit,
        ),
      );
      await tester.pump();

      // Tap twice rapidly — first call is still in progress,
      // so the guard should prevent the second.
      await tester.tap(find.text('Share poem'));
      await tester.tap(find.text('Share poem'));
      await tester.pump();

      verify(
        () => mockService.shareText(
          text: any(named: 'text'),
          subject: any(named: 'subject'),
          sharePositionOrigin: any(named: 'sharePositionOrigin'),
        ),
      ).called(1);

      // Clean up the pending share so the cubit can close.
      shareCompleter.complete(PoemShareResult.completed);
      await tester.pump();
      await shareCubit.close();
    });

    testWidgets('small-screen layout does not overflow', (tester) async {
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
    });
  });
}
