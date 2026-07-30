// ignore_for_file: unawaited_futures

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:daily_stanza/app.dart';
import 'package:daily_stanza/core/router/app_router.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/daily_poem_result.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/poem.dart';
import 'package:daily_stanza/features/daily_poem/domain/repository/poem_repository.dart';
import 'package:daily_stanza/features/favourites/domain/repository/favourites_repository.dart';
import 'package:daily_stanza/features/favourites/presentation/cubit/favourites_cubit.dart';
import 'package:daily_stanza/features/settings/domain/model/poem_language.dart';
import 'package:daily_stanza/features/settings/domain/model/theme_preference.dart';
import 'package:daily_stanza/features/settings/domain/repository/language_preferences_repository.dart';
import 'package:daily_stanza/features/settings/domain/model/app_info.dart';
import 'package:daily_stanza/features/settings/domain/repository/theme_preferences_repository.dart';
import 'package:daily_stanza/features/settings/domain/service/app_info_service.dart';
import 'package:daily_stanza/features/settings/domain/service/external_link_launcher.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/language_preferences_cubit.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/theme_preferences_cubit.dart';

class _MockPoemRepository extends Mock implements PoemRepository {}

class _MockFavouritesRepository extends Mock implements FavouritesRepository {}

class _MockLanguagePreferencesRepository extends Mock
    implements LanguagePreferencesRepository {}

class _MockThemePreferencesRepository extends Mock
    implements ThemePreferencesRepository {}

class _MockAppInfoService extends Mock implements AppInfoService {}

class _MockExternalLinkLauncher extends Mock implements ExternalLinkLauncher {}

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

/// Builds an App-wrapped composition that includes all required providers
/// and exposes the ThemePreferencesCubit externally.
class _AppBundle {
  _AppBundle({required this.app, required this.themeCubit});

  final Widget app;
  final ThemePreferencesCubit themeCubit;
}

_AppBundle _buildApp({
  required PoemRepository poemRepository,
  required FavouritesRepository favouritesRepository,
  required LanguagePreferencesRepository languagePreferencesRepository,
  required ThemePreferencesRepository themePreferencesRepository,
  required PoemLanguage initialLanguage,
  required ThemePreference initialPreference,
  required GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
}) {
  final themeCubit = ThemePreferencesCubit(
    repository: themePreferencesRepository,
    initialPreference: initialPreference,
  );
  final mockAppInfoService = _MockAppInfoService();
  when(() => mockAppInfoService.getAppInfo()).thenAnswer(
    (_) async => const AppInfo(
      appName: 'Daily Stanza',
      version: '1.0.0',
      buildNumber: '1',
    ),
  );
  final mockExternalLinkLauncher = _MockExternalLinkLauncher();
  when(
    () => mockExternalLinkLauncher.launchUrl(any()),
  ).thenAnswer((_) async => true);

  final app = MultiRepositoryProvider(
    providers: [
      RepositoryProvider<PoemRepository>.value(value: poemRepository),
      RepositoryProvider<FavouritesRepository>.value(
        value: favouritesRepository,
      ),
      RepositoryProvider<LanguagePreferencesRepository>.value(
        value: languagePreferencesRepository,
      ),
      RepositoryProvider<ThemePreferencesRepository>.value(
        value: themePreferencesRepository,
      ),
      RepositoryProvider<AppInfoService>.value(value: mockAppInfoService),
      RepositoryProvider<ExternalLinkLauncher>.value(
        value: mockExternalLinkLauncher,
      ),
    ],
    child: MultiBlocProvider(
      providers: [
        BlocProvider<FavouritesCubit>(
          create: (_) => FavouritesCubit(
            favouritesRepository: favouritesRepository,
            poemRepository: poemRepository,
          )..loadFavourites(),
        ),
        BlocProvider<LanguagePreferencesCubit>(
          create: (_) => LanguagePreferencesCubit(
            repository: languagePreferencesRepository,
            initialLanguage: initialLanguage,
          ),
        ),
        BlocProvider<ThemePreferencesCubit>.value(value: themeCubit),
      ],
      child: App(scaffoldMessengerKey: scaffoldMessengerKey),
    ),
  );

  return _AppBundle(app: app, themeCubit: themeCubit);
}

void main() {
  late _MockPoemRepository mockPoemRepo;
  late _MockFavouritesRepository mockFavRepo;
  late _MockLanguagePreferencesRepository mockLangRepo;
  late _MockThemePreferencesRepository mockThemeRepo;
  late GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  setUpAll(() {
    registerFallbackValue(PoemLanguage.english);
    registerFallbackValue(PoemLanguage.polish);
    registerFallbackValue(ThemePreference.system);
    registerFallbackValue(ThemePreference.light);
    registerFallbackValue(ThemePreference.dark);
    registerFallbackValue(Uri());
  });

  setUp(() {
    mockPoemRepo = _MockPoemRepository();
    mockFavRepo = _MockFavouritesRepository();
    mockLangRepo = _MockLanguagePreferencesRepository();
    mockThemeRepo = _MockThemePreferencesRepository();
    scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

    when(
      () => mockPoemRepo.getDailyPoem(
        date: any(named: 'date'),
        languageCode: any(named: 'languageCode'),
      ),
    ).thenAnswer(
      (_) async => const DailyPoemResult(poem: _testPoem, isFromCache: false),
    );
    when(() => mockFavRepo.getFavouritePoemIds()).thenAnswer((_) async => []);
    when(
      () => mockLangRepo.getPreferredLanguage(),
    ).thenAnswer((_) async => PoemLanguage.english);
  });

  group('App theme-mode integration', () {
    testWidgets('System preference maps to ThemeMode.system', (tester) async {
      when(
        () => mockThemeRepo.getPreferredTheme(),
      ).thenAnswer((_) async => ThemePreference.system);

      final bundle = _buildApp(
        poemRepository: mockPoemRepo,
        favouritesRepository: mockFavRepo,
        languagePreferencesRepository: mockLangRepo,
        themePreferencesRepository: mockThemeRepo,
        initialLanguage: PoemLanguage.english,
        initialPreference: ThemePreference.system,
        scaffoldMessengerKey: scaffoldMessengerKey,
      );

      await tester.pumpWidget(bundle.app);
      await tester.pump();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.system);

      bundle.themeCubit.close();
    });

    testWidgets('Light preference maps to ThemeMode.light', (tester) async {
      when(
        () => mockThemeRepo.getPreferredTheme(),
      ).thenAnswer((_) async => ThemePreference.light);

      final bundle = _buildApp(
        poemRepository: mockPoemRepo,
        favouritesRepository: mockFavRepo,
        languagePreferencesRepository: mockLangRepo,
        themePreferencesRepository: mockThemeRepo,
        initialLanguage: PoemLanguage.english,
        initialPreference: ThemePreference.light,
        scaffoldMessengerKey: scaffoldMessengerKey,
      );

      await tester.pumpWidget(bundle.app);
      await tester.pump();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.light);

      bundle.themeCubit.close();
    });

    testWidgets('Dark preference maps to ThemeMode.dark', (tester) async {
      when(
        () => mockThemeRepo.getPreferredTheme(),
      ).thenAnswer((_) async => ThemePreference.dark);

      final bundle = _buildApp(
        poemRepository: mockPoemRepo,
        favouritesRepository: mockFavRepo,
        languagePreferencesRepository: mockLangRepo,
        themePreferencesRepository: mockThemeRepo,
        initialLanguage: PoemLanguage.english,
        initialPreference: ThemePreference.dark,
        scaffoldMessengerKey: scaffoldMessengerKey,
      );

      await tester.pumpWidget(bundle.app);
      await tester.pump();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.dark);

      bundle.themeCubit.close();
    });

    testWidgets('MaterialApp.router receives the current ThemeMode', (
      tester,
    ) async {
      when(
        () => mockThemeRepo.getPreferredTheme(),
      ).thenAnswer((_) async => ThemePreference.system);

      final bundle = _buildApp(
        poemRepository: mockPoemRepo,
        favouritesRepository: mockFavRepo,
        languagePreferencesRepository: mockLangRepo,
        themePreferencesRepository: mockThemeRepo,
        initialLanguage: PoemLanguage.english,
        initialPreference: ThemePreference.system,
        scaffoldMessengerKey: scaffoldMessengerKey,
      );

      await tester.pumpWidget(bundle.app);
      await tester.pump();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, isNotNull);
      expect(materialApp.theme, isNotNull);
      expect(materialApp.darkTheme, isNotNull);
      expect(materialApp.routerConfig, appRouter);

      bundle.themeCubit.close();
    });

    testWidgets(
      'changing preference updates ThemeMode immediately after success',
      (tester) async {
        when(
          () => mockThemeRepo.getPreferredTheme(),
        ).thenAnswer((_) async => ThemePreference.system);
        when(
          () => mockThemeRepo.setPreferredTheme(any()),
        ).thenAnswer((_) async {});

        final bundle = _buildApp(
          poemRepository: mockPoemRepo,
          favouritesRepository: mockFavRepo,
          languagePreferencesRepository: mockLangRepo,
          themePreferencesRepository: mockThemeRepo,
          initialLanguage: PoemLanguage.english,
          initialPreference: ThemePreference.system,
          scaffoldMessengerKey: scaffoldMessengerKey,
        );

        await tester.pumpWidget(bundle.app);
        await tester.pump();

        // Initially system
        MaterialApp materialApp = tester.widget<MaterialApp>(
          find.byType(MaterialApp),
        );
        expect(materialApp.themeMode, ThemeMode.system);

        // Change to light
        bundle.themeCubit.changeTheme(ThemePreference.light);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(materialApp.themeMode, ThemeMode.light);

        bundle.themeCubit.close();
      },
    );

    testWidgets('saving-only state does not change ThemeMode', (tester) async {
      final neverCompleter = Completer<void>();

      when(
        () => mockThemeRepo.getPreferredTheme(),
      ).thenAnswer((_) async => ThemePreference.system);
      when(
        () => mockThemeRepo.setPreferredTheme(any()),
      ).thenAnswer((_) => neverCompleter.future);

      addTearDown(() => neverCompleter.complete());

      final bundle = _buildApp(
        poemRepository: mockPoemRepo,
        favouritesRepository: mockFavRepo,
        languagePreferencesRepository: mockLangRepo,
        themePreferencesRepository: mockThemeRepo,
        initialLanguage: PoemLanguage.english,
        initialPreference: ThemePreference.system,
        scaffoldMessengerKey: scaffoldMessengerKey,
      );

      await tester.pumpWidget(bundle.app);
      await tester.pump();

      bundle.themeCubit.changeTheme(ThemePreference.dark);
      await tester.pump(); // emit isSaving=true

      // ThemeMode should still be system while saving
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.system);

      bundle.themeCubit.close();
    });

    testWidgets('failed save does not change ThemeMode', (tester) async {
      when(
        () => mockThemeRepo.getPreferredTheme(),
      ).thenAnswer((_) async => ThemePreference.system);
      when(
        () => mockThemeRepo.setPreferredTheme(any()),
      ).thenThrow(Exception('fail'));

      final bundle = _buildApp(
        poemRepository: mockPoemRepo,
        favouritesRepository: mockFavRepo,
        languagePreferencesRepository: mockLangRepo,
        themePreferencesRepository: mockThemeRepo,
        initialLanguage: PoemLanguage.english,
        initialPreference: ThemePreference.system,
        scaffoldMessengerKey: scaffoldMessengerKey,
      );

      await tester.pumpWidget(bundle.app);
      await tester.pump();

      bundle.themeCubit.changeTheme(ThemePreference.dark);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.system);

      bundle.themeCubit.close();
    });

    testWidgets('current route remains unchanged after theme change', (
      tester,
    ) async {
      when(
        () => mockThemeRepo.getPreferredTheme(),
      ).thenAnswer((_) async => ThemePreference.system);
      when(
        () => mockThemeRepo.setPreferredTheme(any()),
      ).thenAnswer((_) async {});

      final bundle = _buildApp(
        poemRepository: mockPoemRepo,
        favouritesRepository: mockFavRepo,
        languagePreferencesRepository: mockLangRepo,
        themePreferencesRepository: mockThemeRepo,
        initialLanguage: PoemLanguage.english,
        initialPreference: ThemePreference.system,
        scaffoldMessengerKey: scaffoldMessengerKey,
      );

      await tester.pumpWidget(bundle.app);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Navigate to settings
      await tester.tap(find.text('Settings'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Appearance'), findsOneWidget);

      // Change theme
      bundle.themeCubit.changeTheme(ThemePreference.dark);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should still be on settings
      expect(find.text('Appearance'), findsOneWidget);

      bundle.themeCubit.close();
    });

    testWidgets('appRouter is not recreated', (tester) async {
      when(
        () => mockThemeRepo.getPreferredTheme(),
      ).thenAnswer((_) async => ThemePreference.system);
      when(
        () => mockThemeRepo.setPreferredTheme(any()),
      ).thenAnswer((_) async {});

      final bundle = _buildApp(
        poemRepository: mockPoemRepo,
        favouritesRepository: mockFavRepo,
        languagePreferencesRepository: mockLangRepo,
        themePreferencesRepository: mockThemeRepo,
        initialLanguage: PoemLanguage.english,
        initialPreference: ThemePreference.system,
        scaffoldMessengerKey: scaffoldMessengerKey,
      );

      await tester.pumpWidget(bundle.app);
      await tester.pump();

      // Check that the routerConfig is the stable appRouter instance
      MaterialApp materialApp = tester.widget<MaterialApp>(
        find.byType(MaterialApp),
      );
      final initialRouter = materialApp.routerConfig;

      // Change theme
      bundle.themeCubit.changeTheme(ThemePreference.light);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.routerConfig, same(initialRouter));

      bundle.themeCubit.close();
    });

    testWidgets('existing global ScaffoldMessengerKey remains configured', (
      tester,
    ) async {
      when(
        () => mockThemeRepo.getPreferredTheme(),
      ).thenAnswer((_) async => ThemePreference.system);

      final bundle = _buildApp(
        poemRepository: mockPoemRepo,
        favouritesRepository: mockFavRepo,
        languagePreferencesRepository: mockLangRepo,
        themePreferencesRepository: mockThemeRepo,
        initialLanguage: PoemLanguage.english,
        initialPreference: ThemePreference.system,
        scaffoldMessengerKey: scaffoldMessengerKey,
      );

      await tester.pumpWidget(bundle.app);
      await tester.pump();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.scaffoldMessengerKey, scaffoldMessengerKey);

      bundle.themeCubit.close();
    });
  });
}
