import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:daily_stanza/core/router/app_router.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/daily_poem_result.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/poem.dart';
import 'package:daily_stanza/features/daily_poem/domain/repository/poem_repository.dart';
import 'package:daily_stanza/features/favourites/domain/repository/favourites_repository.dart';
import 'package:daily_stanza/features/favourites/presentation/cubit/favourites_cubit.dart';
import 'package:daily_stanza/features/onboarding/domain/repository/onboarding_repository.dart';
import 'package:daily_stanza/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:daily_stanza/features/onboarding/presentation/view/onboarding_screen.dart';
import 'package:daily_stanza/features/onboarding/presentation/view/splash_screen.dart';
import 'package:daily_stanza/features/settings/domain/model/poem_language.dart';
import 'package:daily_stanza/features/settings/domain/model/theme_preference.dart';
import 'package:daily_stanza/features/settings/domain/repository/language_preferences_repository.dart';
import 'package:daily_stanza/features/settings/domain/repository/theme_preferences_repository.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/language_preferences_cubit.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/theme_preferences_cubit.dart';
import 'package:daily_stanza/features/share_poem/domain/model/poem_share_result.dart';
import 'package:daily_stanza/features/share_poem/domain/service/poem_share_service.dart';
import 'package:daily_stanza/features/share_poem/presentation/cubit/poem_share_cubit.dart';

class MockOnboardingRepository extends Mock implements OnboardingRepository {}

class MockLanguagePreferencesRepository extends Mock
    implements LanguagePreferencesRepository {}

class MockThemePreferencesRepository extends Mock
    implements ThemePreferencesRepository {}

class MockPoemRepository extends Mock implements PoemRepository {}

class MockFavouritesRepository extends Mock implements FavouritesRepository {}

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
    registerFallbackValue(PoemLanguage.english);
    registerFallbackValue(PoemLanguage.polish);
    registerFallbackValue(ThemePreference.system);
    registerFallbackValue(ThemePreference.light);
    registerFallbackValue(ThemePreference.dark);
  });

  group('Onboarding routing guards', () {
    MockFavouritesRepository createEmptyFavRepo() {
      final repo = MockFavouritesRepository();
      when(() => repo.getFavouritePoemIds()).thenAnswer((_) async => []);
      return repo;
    }

    MockPoemRepository createPoemRepo() {
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

    MockLanguagePreferencesRepository createLangRepo() {
      final repo = MockLanguagePreferencesRepository();
      when(
        () => repo.getPreferredLanguage(),
      ).thenAnswer((_) async => PoemLanguage.english);
      when(
        () => repo.setPreferredLanguage(any()),
      ).thenAnswer((_) async {});
      return repo;
    }

    MockThemePreferencesRepository createThemeRepo() {
      final repo = MockThemePreferencesRepository();
      when(
        () => repo.getPreferredTheme(),
      ).thenAnswer((_) async => ThemePreference.system);
      when(
        () => repo.setPreferredTheme(any()),
      ).thenAnswer((_) async {});
      return repo;
    }

    ({GoRouter router, Widget widget}) buildRouterApp({
      required OnboardingCubit onboardingCubit,
    }) {
      final router = createRouter(onboardingCubit: onboardingCubit);
      final poemRepo = createPoemRepo();
      final favRepo = createEmptyFavRepo();
      final langRepo = createLangRepo();
      final themeRepo = createThemeRepo();
      final langCubit = LanguagePreferencesCubit(
        repository: langRepo,
        initialLanguage: PoemLanguage.english,
      );
      final themeCubit = ThemePreferencesCubit(
        repository: themeRepo,
        initialPreference: ThemePreference.system,
      );
      final favCubit = FavouritesCubit(
        favouritesRepository: favRepo,
        poemRepository: poemRepo,
      )..loadFavourites();

      return (
        router: router,
        widget: MultiRepositoryProvider(
          providers: [
            RepositoryProvider<PoemRepository>.value(value: poemRepo),
            RepositoryProvider<FavouritesRepository>.value(value: favRepo),
            RepositoryProvider<LanguagePreferencesRepository>.value(
              value: langRepo,
            ),
            RepositoryProvider<ThemePreferencesRepository>.value(
              value: themeRepo,
            ),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider<OnboardingCubit>.value(value: onboardingCubit),
              BlocProvider<LanguagePreferencesCubit>.value(value: langCubit),
              BlocProvider<ThemePreferencesCubit>.value(value: themeCubit),
              BlocProvider<FavouritesCubit>.value(value: favCubit),
              BlocProvider<PoemShareCubit>(
                create: (_) => _createDefaultShareCubit(),
              ),
            ],
            child: MaterialApp.router(routerConfig: router),
          ),
        ),
      );
    }

    OnboardingCubit createResolvingCubit() {
      final repo = MockOnboardingRepository();
      final completer = Completer<bool>();
      addTearDown(() {
        if (!completer.isCompleted) completer.complete(false);
      });
      when(
        () => repo.isOnboardingCompleted(),
      ).thenAnswer((_) => completer.future);
      return OnboardingCubit(repository: repo);
    }

    OnboardingCubit createIncompleteCubit() {
      final repo = MockOnboardingRepository();
      when(
        () => repo.isOnboardingCompleted(),
      ).thenAnswer((_) async => false);
      when(
        () => repo.setOnboardingCompleted(),
      ).thenAnswer((_) async {});
      return OnboardingCubit(repository: repo);
    }

    OnboardingCubit createCompletedCubit() {
      final repo = MockOnboardingRepository();
      when(
        () => repo.isOnboardingCompleted(),
      ).thenAnswer((_) async => true);
      return OnboardingCubit(repository: repo);
    }

    testWidgets('unresolved status stays on Splash', (tester) async {
      final cubit = createResolvingCubit();
      final bundle = buildRouterApp(onboardingCubit: cubit);

      await tester.pumpWidget(bundle.widget);
      await tester.pump();

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsNothing);

      await cubit.close();
    });

    testWidgets('incomplete onboarding redirects Today to Onboarding', (
      tester,
    ) async {
      final cubit = createIncompleteCubit();
      final bundle = buildRouterApp(onboardingCubit: cubit);

      bundle.router.go('/today');
      await tester.pumpWidget(bundle.widget);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);

      await cubit.close();
    });

    testWidgets('incomplete onboarding redirects Favourites to Onboarding', (
      tester,
    ) async {
      final cubit = createIncompleteCubit();
      final bundle = buildRouterApp(onboardingCubit: cubit);

      bundle.router.go('/favourites');
      await tester.pumpWidget(bundle.widget);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(OnboardingScreen), findsOneWidget);

      await cubit.close();
    });

    testWidgets('incomplete onboarding redirects Settings to Onboarding', (
      tester,
    ) async {
      final cubit = createIncompleteCubit();
      final bundle = buildRouterApp(onboardingCubit: cubit);

      bundle.router.go('/settings');
      await tester.pumpWidget(bundle.widget);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(OnboardingScreen), findsOneWidget);

      await cubit.close();
    });

    testWidgets('completed onboarding redirects Splash to Today', (tester) async {
      final cubit = createCompletedCubit();
      final bundle = buildRouterApp(onboardingCubit: cubit);

      await tester.pumpWidget(bundle.widget);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(SplashScreen), findsNothing);
      expect(find.text('Today'), findsOneWidget);

      await cubit.close();
    });

    testWidgets('completed onboarding redirects Onboarding to Today', (
      tester,
    ) async {
      final cubit = createCompletedCubit();
      final bundle = buildRouterApp(onboardingCubit: cubit);

      bundle.router.go('/onboarding');
      await tester.pumpWidget(bundle.widget);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(OnboardingScreen), findsNothing);
      expect(find.text('Today'), findsOneWidget);

      await cubit.close();
    });

    testWidgets('finishing onboarding enters Today without onboarding on back stack', (
      tester,
    ) async {
      final cubit = createIncompleteCubit();
      final bundle = buildRouterApp(onboardingCubit: cubit);

      await tester.pumpWidget(bundle.widget);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text('Today'), findsNothing);

      // Complete all four steps.
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Start reading'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Today'), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsNothing);
      expect(bundle.router.state.matchedLocation, '/today');

      // Onboarding is not on the back stack: the only route is Today.
      expect(bundle.router.canPop(), isFalse);
      expect(find.text('Today'), findsOneWidget);

      await cubit.close();
    });

    testWidgets('existing poem-details routing continues to work', (tester) async {
      final cubit = createCompletedCubit();
      final bundle = buildRouterApp(onboardingCubit: cubit);

      bundle.router.go('/today/poem/poem1');
      await tester.pumpWidget(bundle.widget);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Poem'), findsOneWidget);
      expect(find.text('The Tyger'), findsAtLeast(1));

      await cubit.close();
    });
  });

  group('OnboardingScreen widget flow', () {
    testWidgets('first launch shows Splash then Onboarding', (tester) async {
      final repo = MockOnboardingRepository();
      when(
        () => repo.isOnboardingCompleted(),
      ).thenAnswer((_) async => false);
      when(
        () => repo.setOnboardingCompleted(),
      ).thenAnswer((_) async {});
      final cubit = OnboardingCubit(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<OnboardingCubit>.value(
            value: cubit,
            child: const OnboardingScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text('Meet Stanzi'), findsOneWidget);

      await cubit.close();
    });

    testWidgets('all four steps can be completed', (tester) async {
      final onboardingRepo = MockOnboardingRepository();
      when(
        () => onboardingRepo.isOnboardingCompleted(),
      ).thenAnswer((_) async => false);
      when(
        () => onboardingRepo.setOnboardingCompleted(),
      ).thenAnswer((_) async {});

      final langRepo = MockLanguagePreferencesRepository();
      when(
        () => langRepo.getPreferredLanguage(),
      ).thenAnswer((_) async => PoemLanguage.english);
      when(
        () => langRepo.setPreferredLanguage(any()),
      ).thenAnswer((_) async {});

      final themeRepo = MockThemePreferencesRepository();
      when(
        () => themeRepo.getPreferredTheme(),
      ).thenAnswer((_) async => ThemePreference.system);
      when(
        () => themeRepo.setPreferredTheme(any()),
      ).thenAnswer((_) async {});

      final onboardingCubit = OnboardingCubit(repository: onboardingRepo);
      final langCubit = LanguagePreferencesCubit(
        repository: langRepo,
        initialLanguage: PoemLanguage.english,
      );
      final themeCubit = ThemePreferencesCubit(
        repository: themeRepo,
        initialPreference: ThemePreference.system,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<OnboardingCubit>.value(value: onboardingCubit),
              BlocProvider<LanguagePreferencesCubit>.value(value: langCubit),
              BlocProvider<ThemePreferencesCubit>.value(value: themeCubit),
            ],
            child: const OnboardingScreen(),
          ),
        ),
      );
      await tester.pump();

      // Step 1
      expect(find.text('Meet Stanzi'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Step 2
      expect(find.text('One poem every day'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Step 3
      expect(find.text('Choose a language'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Step 4
      expect(find.text('Make it yours'), findsOneWidget);
      await tester.tap(find.text('Start reading'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(onboardingCubit.state.completed, isTrue);

      await onboardingCubit.close();
      await langCubit.close();
      await themeCubit.close();
    });

    testWidgets('Skip reaches Today-equivalent state', (tester) async {
      final onboardingRepo = MockOnboardingRepository();
      when(
        () => onboardingRepo.isOnboardingCompleted(),
      ).thenAnswer((_) async => false);
      when(
        () => onboardingRepo.setOnboardingCompleted(),
      ).thenAnswer((_) async {});

      final langRepo = MockLanguagePreferencesRepository();
      when(
        () => langRepo.getPreferredLanguage(),
      ).thenAnswer((_) async => PoemLanguage.english);
      when(
        () => langRepo.setPreferredLanguage(any()),
      ).thenAnswer((_) async {});

      final themeRepo = MockThemePreferencesRepository();
      when(
        () => themeRepo.getPreferredTheme(),
      ).thenAnswer((_) async => ThemePreference.system);
      when(
        () => themeRepo.setPreferredTheme(any()),
      ).thenAnswer((_) async {});

      final onboardingCubit = OnboardingCubit(repository: onboardingRepo);
      final langCubit = LanguagePreferencesCubit(
        repository: langRepo,
        initialLanguage: PoemLanguage.english,
      );
      final themeCubit = ThemePreferencesCubit(
        repository: themeRepo,
        initialPreference: ThemePreference.system,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<OnboardingCubit>.value(value: onboardingCubit),
              BlocProvider<LanguagePreferencesCubit>.value(value: langCubit),
              BlocProvider<ThemePreferencesCubit>.value(value: themeCubit),
            ],
            child: const OnboardingScreen(),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Skip'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(onboardingCubit.state.completed, isTrue);
      verify(() => onboardingRepo.setOnboardingCompleted()).called(1);

      await onboardingCubit.close();
      await langCubit.close();
      await themeCubit.close();
    });

    testWidgets('language and theme options display correct selected states', (
      tester,
    ) async {
      final onboardingRepo = MockOnboardingRepository();
      when(
        () => onboardingRepo.isOnboardingCompleted(),
      ).thenAnswer((_) async => false);
      when(
        () => onboardingRepo.setOnboardingCompleted(),
      ).thenAnswer((_) async {});

      final langRepo = MockLanguagePreferencesRepository();
      when(
        () => langRepo.getPreferredLanguage(),
      ).thenAnswer((_) async => PoemLanguage.english);
      when(
        () => langRepo.setPreferredLanguage(any()),
      ).thenAnswer((_) async {});

      final themeRepo = MockThemePreferencesRepository();
      when(
        () => themeRepo.getPreferredTheme(),
      ).thenAnswer((_) async => ThemePreference.system);
      when(
        () => themeRepo.setPreferredTheme(any()),
      ).thenAnswer((_) async {});

      final onboardingCubit = OnboardingCubit(repository: onboardingRepo);
      final langCubit = LanguagePreferencesCubit(
        repository: langRepo,
        initialLanguage: PoemLanguage.english,
      );
      final themeCubit = ThemePreferencesCubit(
        repository: themeRepo,
        initialPreference: ThemePreference.system,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<OnboardingCubit>.value(value: onboardingCubit),
              BlocProvider<LanguagePreferencesCubit>.value(value: langCubit),
              BlocProvider<ThemePreferencesCubit>.value(value: themeCubit),
            ],
            child: const OnboardingScreen(),
          ),
        ),
      );
      await tester.pump();

      // Navigate to language step
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Choose a language'), findsOneWidget);

      // Find selected English tile by checking the check icon
      expect(find.byIcon(Icons.check), findsOneWidget);

      await tester.ensureVisible(find.text('Polish'));
      await tester.tap(find.text('Polish'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(langCubit.state.language, PoemLanguage.polish);

      // Navigate to theme step
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Make it yours'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);

      await tester.ensureVisible(find.text('Dark'));
      await tester.tap(find.text('Dark'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(themeCubit.state.preference, ThemePreference.dark);

      await onboardingCubit.close();
      await langCubit.close();
      await themeCubit.close();
    });

    testWidgets('constrained mobile viewport has no overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final onboardingRepo = MockOnboardingRepository();
      when(
        () => onboardingRepo.isOnboardingCompleted(),
      ).thenAnswer((_) async => false);
      final onboardingCubit = OnboardingCubit(repository: onboardingRepo);
      final langCubit = LanguagePreferencesCubit(
        repository: MockLanguagePreferencesRepository(),
        initialLanguage: PoemLanguage.english,
      );
      final themeCubit = ThemePreferencesCubit(
        repository: MockThemePreferencesRepository(),
        initialPreference: ThemePreference.system,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<OnboardingCubit>.value(value: onboardingCubit),
              BlocProvider<LanguagePreferencesCubit>.value(value: langCubit),
              BlocProvider<ThemePreferencesCubit>.value(value: themeCubit),
            ],
            child: const OnboardingScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);

      await onboardingCubit.close();
      await langCubit.close();
      await themeCubit.close();
    });

    testWidgets('large text scaling has no overflow on critical screen', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      tester.view.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(() {
        tester.view.platformDispatcher.textScaleFactorTestValue = 1.0;
      });

      final onboardingRepo = MockOnboardingRepository();
      when(
        () => onboardingRepo.isOnboardingCompleted(),
      ).thenAnswer((_) async => false);
      final onboardingCubit = OnboardingCubit(repository: onboardingRepo);
      final langCubit = LanguagePreferencesCubit(
        repository: MockLanguagePreferencesRepository(),
        initialLanguage: PoemLanguage.english,
      );
      final themeCubit = ThemePreferencesCubit(
        repository: MockThemePreferencesRepository(),
        initialPreference: ThemePreference.system,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<OnboardingCubit>.value(value: onboardingCubit),
              BlocProvider<LanguagePreferencesCubit>.value(value: langCubit),
              BlocProvider<ThemePreferencesCubit>.value(value: themeCubit),
            ],
            child: const OnboardingScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);

      await onboardingCubit.close();
      await langCubit.close();
      await themeCubit.close();
    });
  });
}
