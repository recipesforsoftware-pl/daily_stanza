import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/poem.dart';
import 'package:daily_stanza/features/share_poem/domain/model/poem_share_result.dart';
import 'package:daily_stanza/features/share_poem/domain/service/poem_share_service.dart';
import 'package:daily_stanza/features/share_poem/presentation/cubit/poem_share_cubit.dart';
import 'package:daily_stanza/features/share_poem/presentation/widgets/share_poem_button.dart';

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

Widget _buildApp({required PoemShareCubit cubit, bool showLabel = false}) {
  return MaterialApp(
    home: Scaffold(
      body: BlocProvider<PoemShareCubit>.value(
        value: cubit,
        child: SharePoemButton(
          poem: _testPoem,
          label: showLabel ? 'Share poem' : null,
        ),
      ),
    ),
  );
}

void main() {
  late MockPoemShareService mockService;

  setUp(() {
    mockService = MockPoemShareService();
    registerFallbackValue(const Rect.fromLTWH(0, 0, 0, 0));
  });

  group('SharePoemButton', () {
    testWidgets('icon renders correctly (icon-only mode)', (tester) async {
      final cubit = PoemShareCubit(shareService: mockService);
      await tester.pumpWidget(_buildApp(cubit: cubit));

      expect(find.byIcon(Icons.share), findsOneWidget);
      await cubit.close();
    });

    testWidgets('label renders when provided', (tester) async {
      final cubit = PoemShareCubit(shareService: mockService);
      await tester.pumpWidget(_buildApp(cubit: cubit, showLabel: true));

      expect(find.text('Share poem'), findsOneWidget);
      expect(find.byIcon(Icons.share), findsOneWidget);
      await cubit.close();
    });

    testWidgets('Tooltip is Share poem', (tester) async {
      final cubit = PoemShareCubit(shareService: mockService);
      await tester.pumpWidget(_buildApp(cubit: cubit));

      expect(find.byTooltip('Share poem'), findsOneWidget);
      await cubit.close();
    });

    testWidgets('semantic label is Share poem', (tester) async {
      final cubit = PoemShareCubit(shareService: mockService);
      await tester.pumpWidget(_buildApp(cubit: cubit));

      expect(find.bySemanticsLabel('Share poem'), findsOneWidget);
      await cubit.close();
    });

    testWidgets('tap invokes Cubit sharePoem once', (tester) async {
      when(
        () => mockService.shareText(
          text: any(named: 'text'),
          subject: any(named: 'subject'),
          sharePositionOrigin: any(named: 'sharePositionOrigin'),
        ),
      ).thenAnswer((_) async => PoemShareResult.completed);

      final cubit = PoemShareCubit(shareService: mockService);
      await tester.pumpWidget(_buildApp(cubit: cubit));

      await tester.tap(find.byIcon(Icons.share));
      await tester.pump();

      verify(
        () => mockService.shareText(
          text: any(named: 'text'),
          subject: any(named: 'subject'),
          sharePositionOrigin: any(named: 'sharePositionOrigin'),
        ),
      ).called(1);
      await cubit.close();
    });

    testWidgets('button disabled while sharing', (tester) async {
      final completer = Completer<PoemShareResult>();
      when(
        () => mockService.shareText(
          text: any(named: 'text'),
          subject: any(named: 'subject'),
          sharePositionOrigin: any(named: 'sharePositionOrigin'),
        ),
      ).thenAnswer((_) => completer.future);

      final cubit = PoemShareCubit(shareService: mockService);
      await tester.pumpWidget(_buildApp(cubit: cubit));

      // Start sharing (never completes)
      unawaited(cubit.sharePoem(_testPoem));
      await tester.pump();

      // Button should show progress indicator instead of share icon
      expect(find.byIcon(Icons.share), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await cubit.close();
    });

    testWidgets('progress state shown while sharing', (tester) async {
      final completer = Completer<PoemShareResult>();
      when(
        () => mockService.shareText(
          text: any(named: 'text'),
          subject: any(named: 'subject'),
          sharePositionOrigin: any(named: 'sharePositionOrigin'),
        ),
      ).thenAnswer((_) => completer.future);

      final cubit = PoemShareCubit(shareService: mockService);
      await tester.pumpWidget(_buildApp(cubit: cubit));

      unawaited(cubit.sharePoem(_testPoem));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await cubit.close();
    });

    testWidgets('origin Rect is non-null when rendered', (tester) async {
      late Rect? capturedOrigin;
      when(
        () => mockService.shareText(
          text: any(named: 'text'),
          subject: any(named: 'subject'),
          sharePositionOrigin: captureAny(named: 'sharePositionOrigin'),
        ),
      ).thenAnswer((invocation) async {
        capturedOrigin =
            invocation.namedArguments[#sharePositionOrigin] as Rect?;
        return PoemShareResult.completed;
      });

      final cubit = PoemShareCubit(shareService: mockService);
      await tester.pumpWidget(_buildApp(cubit: cubit));

      await tester.tap(find.byIcon(Icons.share));
      await tester.pump();

      // When rendered in the test, the RenderBox should be available
      // and produce a non-null origin rect.
      expect(capturedOrigin, isNotNull);
      expect(capturedOrigin!.width, greaterThan(0));
      expect(capturedOrigin!.height, greaterThan(0));
      await cubit.close();
    });

    testWidgets('no overflow with text scaling', (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(
        () => binding.platformDispatcher.clearTextScaleFactorTestValue(),
      );

      final cubit = PoemShareCubit(shareService: mockService);
      await tester.pumpWidget(_buildApp(cubit: cubit, showLabel: true));

      expect(tester.takeException(), isNull);
      await cubit.close();
    });

    testWidgets('uses secondary color from theme in light and dark themes', (
      tester,
    ) async {
      final cubit = PoemShareCubit(shareService: mockService);

      for (final brightness in [Brightness.light, Brightness.dark]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: brightness == Brightness.light
                ? ThemeMode.light
                : ThemeMode.dark,
            home: Scaffold(
              body: BlocProvider<PoemShareCubit>.value(
                value: cubit,
                child: const SharePoemButton(
                  poem: _testPoem,
                  label: 'Share poem',
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        final button = tester.widget<TextButton>(find.byType(TextButton));
        final resolvedColor = button.style?.foregroundColor?.resolve({});
        final themeColor = Theme.of(
          tester.element(find.byType(TextButton)),
        ).colorScheme.secondary;

        expect(resolvedColor, equals(themeColor));
      }

      await cubit.close();
    });
  });
}
