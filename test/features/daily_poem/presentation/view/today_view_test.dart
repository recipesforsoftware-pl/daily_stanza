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

class MockPoemRepository extends Mock implements PoemRepository {}

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

class MockDailyPoemBloc extends Mock implements DailyPoemBloc {}

void main() {
  setUpAll(() {
    registerFallbackValue(const DailyPoemRetryRequested());
    registerFallbackValue(
      DailyPoemRequested(date: DateTime(2026, 7, 28), languageCode: 'en'),
    );
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

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DailyPoemBloc>.value(
            value: bloc,
            child: const TodayView(),
          ),
        ),
      );
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

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DailyPoemBloc>.value(
            value: bloc,
            child: const TodayView(),
          ),
        ),
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

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DailyPoemBloc>.value(
            value: bloc,
            child: const TodayView(),
          ),
        ),
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

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DailyPoemBloc>.value(
            value: bloc,
            child: const TodayView(),
          ),
        ),
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

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DailyPoemBloc>.value(
            value: bloc,
            child: const TodayView(),
          ),
        ),
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

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DailyPoemBloc>.value(
            value: bloc,
            child: const TodayView(),
          ),
        ),
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

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DailyPoemBloc>.value(
            value: bloc,
            child: const TodayView(),
          ),
        ),
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

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DailyPoemBloc>.value(
            value: bloc,
            child: const TodayView(),
          ),
        ),
      );
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

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DailyPoemBloc>.value(
            value: bloc,
            child: const TodayView(),
          ),
        ),
      );
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

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DailyPoemBloc>.value(
            value: bloc,
            child: const TodayView(),
          ),
        ),
      );
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

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DailyPoemBloc>.value(
            value: bloc,
            child: const TodayView(),
          ),
        ),
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

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<DailyPoemBloc>.value(
              value: bloc,
              child: const TodayView(),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      },
    );
  });
}
