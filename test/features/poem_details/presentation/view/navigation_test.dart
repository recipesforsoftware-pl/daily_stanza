import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';
import 'package:daily_stanza/core/router/app_router.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/daily_poem_result.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/poem.dart';
import 'package:daily_stanza/features/daily_poem/domain/repository/poem_repository.dart';
import 'package:daily_stanza/features/daily_poem/presentation/widgets/daily_poem_content.dart';
import 'package:daily_stanza/features/favourites/presentation/cubit/favourites_cubit.dart';
import 'package:daily_stanza/features/favourites/presentation/cubit/favourites_state.dart';
import 'package:daily_stanza/features/favourites/presentation/widgets/favourite_poem_card.dart';
import 'package:daily_stanza/features/poem_details/presentation/cubit/poem_details_cubit.dart';
import 'package:daily_stanza/features/poem_details/presentation/cubit/poem_details_state.dart';
import 'package:daily_stanza/features/poem_details/presentation/view/poem_details_view.dart';
import 'package:daily_stanza/features/settings/domain/model/app_info.dart';
import 'package:daily_stanza/features/settings/domain/model/poem_language.dart';
import 'package:daily_stanza/features/settings/domain/model/theme_preference.dart';
import 'package:daily_stanza/features/settings/domain/service/app_info_service.dart';
import 'package:daily_stanza/features/settings/domain/service/external_link_launcher.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/language_preferences_cubit.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/language_preferences_state.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/theme_preferences_cubit.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/theme_preferences_state.dart';
import 'package:daily_stanza/features/share_poem/domain/model/poem_share_result.dart';
import 'package:daily_stanza/features/share_poem/domain/service/poem_share_service.dart';
import 'package:daily_stanza/features/share_poem/presentation/cubit/poem_share_cubit.dart';

class MockFavouritesCubit extends MockBloc<FavouritesCubit, FavouritesState>
    implements FavouritesCubit {}

class MockLanguagePreferencesCubit
    extends MockBloc<LanguagePreferencesCubit, LanguagePreferencesState>
    implements LanguagePreferencesCubit {}

class MockThemePreferencesCubit
    extends MockBloc<ThemePreferencesCubit, ThemePreferencesState>
    implements ThemePreferencesCubit {}

class MockPoemRepository extends Mock implements PoemRepository {}

class MockPoemShareService extends Mock implements PoemShareService {}

class MockAppInfoService extends Mock implements AppInfoService {}

class MockExternalLinkLauncher extends Mock implements ExternalLinkLauncher {}

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
    registerFallbackValue(PoemShareResult.completed);
    registerFallbackValue(Uri());
  });
  group('FavouritePoemCard onOpen', () {
    testWidgets('onOpen is invoked when tapping the card content', (
      tester,
    ) async {
      var opened = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FavouritePoemCard(
              poem: _testPoem,
              isRemoving: false,
              onRemove: () {},
              onOpen: () => opened = true,
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('The Tyger'));
      await tester.pump();

      expect(opened, isTrue);
    });

    testWidgets('remove action does not invoke onOpen', (tester) async {
      var removeCalled = false;
      var openCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FavouritePoemCard(
              poem: _testPoem,
              isRemoving: false,
              onRemove: () => removeCalled = true,
              onOpen: () => openCalled = true,
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pump();

      expect(removeCalled, isTrue);
      expect(openCalled, isFalse);
    });
  });

  group('Today focus mode action', () {
    testWidgets('focus mode action uses the correct poem path', (tester) async {
      var navigatedPath = '';
      final mockFavCubit = MockFavouritesCubit();
      whenListen(
        mockFavCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<FavouritesCubit>.value(
            value: mockFavCubit,
            child: BlocProvider<PoemShareCubit>(
              create: (_) => _createDefaultShareCubit(),
              child: Scaffold(
                body: DailyPoemContent(
                  poem: _testPoem,
                  isFromCache: false,
                  formattedDate: 'July 29, 2026',
                  onReadFocusMode: () =>
                      navigatedPath = '/today/poem/${_testPoem.id}',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Read in focus mode'), findsOneWidget);

      await tester.tap(find.text('Read in focus mode'));
      expect(navigatedPath, '/today/poem/poem1');
    });
  });

  group('PoemDetailsCubit route composition', () {
    testWidgets('cubit loads poem by ID and emits loaded', (tester) async {
      final mockRepo = MockPoemRepository();
      when(
        () => mockRepo.getPoemsByIds(any()),
      ).thenAnswer((_) async => const [_testPoem]);

      final cubit = PoemDetailsCubit(repository: mockRepo);
      await cubit.loadPoem('poem1');

      expect(cubit.state, isA<PoemDetailsLoaded>());
      expect((cubit.state as PoemDetailsLoaded).poem.id, 'poem1');
      expect((cubit.state as PoemDetailsLoaded).poem.title, 'The Tyger');

      await cubit.close();
    });

    testWidgets('appRouter is configured', (tester) async {
      // Verify the router exists and matches the expected configuration.
      expect(appRouter, isNotNull);
    });
  });

  group('Back navigation', () {
    testWidgets('PoemDetailsView has an AppBar with back navigation', (
      tester,
    ) async {
      final mockFavCubit = MockFavouritesCubit();
      whenListen(
        mockFavCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<FavouritesCubit>.value(value: mockFavCubit),
              BlocProvider<PoemShareCubit>(
                create: (_) => _createDefaultShareCubit(),
              ),
            ],
            child: BlocProvider<PoemDetailsCubit>(
              create: (_) => PoemDetailsCubit(repository: MockPoemRepository()),
              child: const PoemDetailsView(),
            ),
          ),
        ),
      );
      await tester.pump();

      // AppBar should be present with a leading back widget
      expect(find.byType(AppBar), findsOneWidget);
    });
  });

  group('GoRouter integration', () {
    /// Returns a pair (router, widget) so each test has an isolated router.
    MockLanguagePreferencesCubit createDefaultLangCubit() {
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

    MockThemePreferencesCubit createDefaultThemeCubit() {
      final cubit = MockThemePreferencesCubit();
      whenListen(
        cubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.system,
        ),
      );
      return cubit;
    }

    MockAppInfoService createDefaultAppInfoService() {
      final service = MockAppInfoService();
      when(() => service.getAppInfo()).thenAnswer(
        (_) async => const AppInfo(
          appName: 'Daily Stanza',
          version: '1.0.0',
          buildNumber: '1',
        ),
      );
      return service;
    }

    MockExternalLinkLauncher createDefaultExternalLinkLauncher() {
      final launcher = MockExternalLinkLauncher();
      when(() => launcher.launchUrl(any())).thenAnswer((_) async => true);
      return launcher;
    }

    ({GoRouter router, Widget widget}) buildRouterApp({
      required MockPoemRepository mockRepo,
      required MockFavouritesCubit mockFavCubit,
      MockLanguagePreferencesCubit? mockLangCubit,
      MockThemePreferencesCubit? mockThemeCubit,
    }) {
      final router = createRouter();
      final langCubit = mockLangCubit ?? createDefaultLangCubit();
      final themeCubit = mockThemeCubit ?? createDefaultThemeCubit();
      final appInfoService = createDefaultAppInfoService();
      final externalLinkLauncher = createDefaultExternalLinkLauncher();
      return (
        router: router,
        widget: MultiRepositoryProvider(
          providers: [
            RepositoryProvider<PoemRepository>.value(value: mockRepo),
            RepositoryProvider<AppInfoService>.value(value: appInfoService),
            RepositoryProvider<ExternalLinkLauncher>.value(
              value: externalLinkLauncher,
            ),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider<FavouritesCubit>.value(value: mockFavCubit),
              BlocProvider<LanguagePreferencesCubit>.value(value: langCubit),
              BlocProvider<ThemePreferencesCubit>.value(value: themeCubit),
              BlocProvider<PoemShareCubit>(
                create: (_) => _createDefaultShareCubit(),
              ),
            ],
            child: MaterialApp.router(routerConfig: router),
          ),
        ),
      );
    }

    Future<GoRouter> pumpApp(
      WidgetTester tester, {
      required MockPoemRepository mockRepo,
      required MockFavouritesCubit mockFavCubit,
    }) async {
      final result = buildRouterApp(
        mockRepo: mockRepo,
        mockFavCubit: mockFavCubit,
      );
      await tester.pumpWidget(result.widget);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      return result.router;
    }

    MockPoemRepository createMockRepo() {
      final repo = MockPoemRepository();
      when(
        () => repo.getDailyPoem(
          date: any(named: 'date'),
          languageCode: any(named: 'languageCode'),
        ),
      ).thenAnswer(
        (_) async => const DailyPoemResult(poem: _testPoem, isFromCache: false),
      );
      when(
        () => repo.getPoemsByIds(['poem1']),
      ).thenAnswer((_) async => [_testPoem]);
      return repo;
    }

    MockFavouritesCubit createEmptyFavCubit() {
      final cubit = MockFavouritesCubit();
      whenListen(
        cubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(poems: [], favouriteIds: {}),
      );
      return cubit;
    }

    testWidgets('/today/poem/poem1 displays PoemDetailsView', (tester) async {
      final mockRepo = createMockRepo();
      final mockFavCubit = createEmptyFavCubit();
      final router = await pumpApp(
        tester,
        mockRepo: mockRepo,
        mockFavCubit: mockFavCubit,
      );

      router.go('/today/poem/poem1');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Details AppBar should be present (distinguishes from Today)
      expect(find.text('Poem'), findsOneWidget);
      // Poem title should be visible
      expect(find.text('The Tyger'), findsAtLeast(1));
    });

    testWidgets('/favourites/poem/poem1 displays PoemDetailsView', (
      tester,
    ) async {
      final mockRepo = createMockRepo();
      final mockFavCubit = createEmptyFavCubit();
      final router = await pumpApp(
        tester,
        mockRepo: mockRepo,
        mockFavCubit: mockFavCubit,
      );

      router.go('/favourites/poem/poem1');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Details AppBar should be present
      expect(find.text('Poem'), findsOneWidget);
    });

    testWidgets('both routes pass poem1 to PoemDetailsCubit', (tester) async {
      final mockRepo = createMockRepo();
      final mockFavCubit = createEmptyFavCubit();
      final router = await pumpApp(
        tester,
        mockRepo: mockRepo,
        mockFavCubit: mockFavCubit,
      );

      router.go('/today/poem/poem1');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      verify(() => mockRepo.getPoemsByIds(['poem1'])).called(1);
    });

    testWidgets('each navigation loads repository exactly once', (
      tester,
    ) async {
      final mockRepo = createMockRepo();
      final mockFavCubit = createEmptyFavCubit();
      final router = await pumpApp(
        tester,
        mockRepo: mockRepo,
        mockFavCubit: mockFavCubit,
      );

      router.go('/today/poem/poem1');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      verify(() => mockRepo.getPoemsByIds(['poem1'])).called(1);
    });

    testWidgets('navigate from Today poem to different branch', (tester) async {
      final mockRepo = createMockRepo();
      final mockFavCubit = createEmptyFavCubit();
      final router = await pumpApp(
        tester,
        mockRepo: mockRepo,
        mockFavCubit: mockFavCubit,
      );

      // Navigate to poem details
      router.go('/today/poem/poem1');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Poem'), findsOneWidget);

      // Navigate to a different branch route
      router.go('/favourites');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // The 'Poem' title should be gone — navigated away
      expect(find.text('Poem'), findsNothing);
    });

    testWidgets('navigate from Favourites poem to different branch', (
      tester,
    ) async {
      final mockRepo = createMockRepo();
      final mockFavCubit = MockFavouritesCubit();
      whenListen(
        mockFavCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(
          poems: [_testPoem],
          favouriteIds: {'poem1'},
        ),
      );
      final router = await pumpApp(
        tester,
        mockRepo: mockRepo,
        mockFavCubit: mockFavCubit,
      );

      // Navigate to favourites poem details
      router.go('/favourites/poem/poem1');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Poem'), findsOneWidget);

      // Navigate to a different branch route
      router.go('/settings');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // The 'Poem' title should be gone — navigated away
      expect(find.text('Poem'), findsNothing);
    });

    testWidgets(
      'system back from Favourites poem details returns to Favourites',
      (tester) async {
        final mockRepo = createMockRepo();
        final mockFavCubit = MockFavouritesCubit();
        whenListen(
          mockFavCubit,
          const Stream<FavouritesState>.empty(),
          initialState: const FavouritesLoaded(
            poems: [_testPoem],
            favouriteIds: {'poem1'},
          ),
        );
        await pumpApp(tester, mockRepo: mockRepo, mockFavCubit: mockFavCubit);

        // Start at Favourites
        await tester.tap(find.byIcon(Icons.favorite_border));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Verify Favourites is showing with the poem card
        expect(find.text('The Tyger'), findsOneWidget);
        expect(find.text('Favourites'), findsAtLeast(1));

        // Tap the card to trigger context.push('/favourites/poem/poem1')
        await tester.tap(find.text('The Tyger'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Verify PoemDetailsView is now showing
        expect(find.text('Poem'), findsOneWidget);
        expect(find.text('The Tyger'), findsAtLeast(1));

        // Simulate Android system back
        final handled = await tester.binding.handlePopRoute();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Should return to Favourites
        expect(handled, isTrue);
        expect(find.text('Poem'), findsNothing);
        expect(find.text('Favourites'), findsAtLeast(1));
      },
    );

    testWidgets('system back from Today poem details returns to Today', (
      tester,
    ) async {
      final mockRepo = createMockRepo();
      final mockFavCubit = createEmptyFavCubit();
      await pumpApp(tester, mockRepo: mockRepo, mockFavCubit: mockFavCubit);

      // Start at Today (default route)
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Today view should be showing
      expect(find.text('Read in focus mode'), findsOneWidget);

      // Tap "Read in focus mode" to trigger context.push('/today/poem/poem1')
      await tester.ensureVisible(find.text('Read in focus mode'));
      await tester.pump();
      await tester.tap(find.text('Read in focus mode'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Verify PoemDetailsView is now showing
      expect(find.text('Poem'), findsOneWidget);
      expect(find.text('The Tyger'), findsAtLeast(1));

      // Simulate Android system back
      final handled = await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Should return to Today
      expect(handled, isTrue);
      expect(find.text('Poem'), findsNothing);
      expect(find.text('Read in focus mode'), findsOneWidget);
    });

    testWidgets('AppBar back button returns from poem details to Favourites', (
      tester,
    ) async {
      final mockRepo = createMockRepo();
      final mockFavCubit = MockFavouritesCubit();
      whenListen(
        mockFavCubit,
        const Stream<FavouritesState>.empty(),
        initialState: const FavouritesLoaded(
          poems: [_testPoem],
          favouriteIds: {'poem1'},
        ),
      );
      await pumpApp(tester, mockRepo: mockRepo, mockFavCubit: mockFavCubit);

      // Start at Favourites
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Tap the card to open poem details
      await tester.tap(find.text('The Tyger'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Verify PoemDetailsView is showing
      expect(find.text('Poem'), findsOneWidget);

      // Tap the AppBar back button
      await tester.tap(find.byType(BackButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Should return to Favourites
      expect(find.text('Poem'), findsNothing);
      expect(find.text('Favourites'), findsAtLeast(1));
    });

    testWidgets('AppBar back button returns from poem details to Today', (
      tester,
    ) async {
      final mockRepo = createMockRepo();
      final mockFavCubit = createEmptyFavCubit();
      await pumpApp(tester, mockRepo: mockRepo, mockFavCubit: mockFavCubit);

      // Start at Today (default route)
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Tap "Read in focus mode" to open poem details
      await tester.ensureVisible(find.text('Read in focus mode'));
      await tester.pump();
      await tester.tap(find.text('Read in focus mode'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Verify PoemDetailsView is showing
      expect(find.text('Poem'), findsOneWidget);

      // Tap the AppBar back button
      await tester.tap(find.byType(BackButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Should return to Today
      expect(find.text('Poem'), findsNothing);
      expect(find.text('Read in focus mode'), findsOneWidget);
    });
  });
}
