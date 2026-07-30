// ignore_for_file: unawaited_futures

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
import 'package:daily_stanza/features/favourites/presentation/cubit/favourites_state.dart';
import 'package:daily_stanza/features/settings/domain/model/poem_language.dart';
import 'package:daily_stanza/features/settings/domain/model/theme_preference.dart';
import 'package:daily_stanza/features/settings/domain/repository/language_preferences_repository.dart';
import 'package:daily_stanza/features/settings/domain/repository/theme_preferences_repository.dart';
import 'package:daily_stanza/features/settings/domain/model/app_info.dart';
import 'package:daily_stanza/features/settings/domain/service/app_info_service.dart';
import 'package:daily_stanza/features/settings/domain/service/external_link_launcher.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/language_preferences_cubit.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/theme_preferences_cubit.dart';
import 'package:daily_stanza/features/share_poem/domain/model/poem_share_result.dart';
import 'package:daily_stanza/features/share_poem/domain/service/poem_share_service.dart';
import 'package:daily_stanza/features/share_poem/presentation/cubit/poem_share_cubit.dart';

class _MockPoemRepository extends Mock implements PoemRepository {}

class _MockFavouritesRepository extends Mock implements FavouritesRepository {}

class _MockLanguagePreferencesRepository extends Mock
    implements LanguagePreferencesRepository {}

class _MockThemePreferencesRepository extends Mock
    implements ThemePreferencesRepository {}

class _MockPoemShareService extends Mock implements PoemShareService {}

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

/// Helper class to bundle the widget tree with accessible cubits.
class _TestBundle {
  _TestBundle({
    required this.app,
    required this.themeCubit,
    required this.langCubit,
    required this.favCubit,
    required this.shareCubit,
    required this.scaffoldMessengerKey,
  });

  final Widget app;
  final ThemePreferencesCubit themeCubit;
  final LanguagePreferencesCubit langCubit;
  final FavouritesCubit favCubit;
  final PoemShareCubit shareCubit;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
}

_TestBundle _buildApp({
  required PoemRepository poemRepository,
  required FavouritesRepository favouritesRepository,
  required LanguagePreferencesRepository languagePreferencesRepository,
  required ThemePreferencesRepository themePreferencesRepository,
  required PoemLanguage initialLanguage,
  required ThemePreference initialPreference,
}) {
  final themeCubit = ThemePreferencesCubit(
    repository: themePreferencesRepository,
    initialPreference: initialPreference,
  );
  final langCubit = LanguagePreferencesCubit(
    repository: languagePreferencesRepository,
    initialLanguage: initialLanguage,
  );
  final favCubit = FavouritesCubit(
    favouritesRepository: favouritesRepository,
    poemRepository: poemRepository,
  );
  final mockShareService = _MockPoemShareService();
  when(
    () => mockShareService.shareText(
      text: any(named: 'text'),
      subject: any(named: 'subject'),
      sharePositionOrigin: any(named: 'sharePositionOrigin'),
    ),
  ).thenAnswer((_) async => PoemShareResult.completed);
  final shareCubit = PoemShareCubit(shareService: mockShareService);

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

  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

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
        BlocProvider<FavouritesCubit>.value(value: favCubit),
        BlocProvider<LanguagePreferencesCubit>.value(value: langCubit),
        BlocProvider<ThemePreferencesCubit>.value(value: themeCubit),
        BlocProvider<PoemShareCubit>.value(value: shareCubit),
      ],
      child: App(scaffoldMessengerKey: scaffoldMessengerKey),
    ),
  );

  return _TestBundle(
    app: app,
    themeCubit: themeCubit,
    langCubit: langCubit,
    favCubit: favCubit,
    shareCubit: shareCubit,
    scaffoldMessengerKey: scaffoldMessengerKey,
  );
}

void main() {
  late _MockPoemRepository mockPoemRepo;
  late _MockFavouritesRepository mockFavRepo;
  late _MockLanguagePreferencesRepository mockLangRepo;
  late _MockThemePreferencesRepository mockThemeRepo;

  setUpAll(() {
    registerFallbackValue(PoemLanguage.english);
    registerFallbackValue(PoemLanguage.polish);
    registerFallbackValue(ThemePreference.system);
    registerFallbackValue(ThemePreference.light);
    registerFallbackValue(ThemePreference.dark);
    registerFallbackValue(_testPoem);
    registerFallbackValue(PoemShareResult.completed);
    registerFallbackValue(Uri());
  });

  setUp(() {
    mockPoemRepo = _MockPoemRepository();
    mockFavRepo = _MockFavouritesRepository();
    mockLangRepo = _MockLanguagePreferencesRepository();
    mockThemeRepo = _MockThemePreferencesRepository();

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
    when(
      () => mockThemeRepo.getPreferredTheme(),
    ).thenAnswer((_) async => ThemePreference.system);
    when(() => mockThemeRepo.setPreferredTheme(any())).thenAnswer((_) async {});
  });

  group('Feature isolation', () {
    testWidgets('theme change does not dispatch DailyPoemRequested', (
      tester,
    ) async {
      final bundle = _buildApp(
        poemRepository: mockPoemRepo,
        favouritesRepository: mockFavRepo,
        languagePreferencesRepository: mockLangRepo,
        themePreferencesRepository: mockThemeRepo,
        initialLanguage: PoemLanguage.english,
        initialPreference: ThemePreference.system,
      );

      await tester.pumpWidget(bundle.app);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Change theme
      bundle.themeCubit.changeTheme(ThemePreference.dark);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // PoemRepository should only have been called once (from initState),
      // not again from the theme change
      verify(
        () => mockPoemRepo.getDailyPoem(
          date: any(named: 'date'),
          languageCode: any(named: 'languageCode'),
        ),
      ).called(1);

      bundle.themeCubit.close();
      bundle.langCubit.close();
      bundle.favCubit.close();
      bundle.shareCubit.close();
    });

    testWidgets('theme change does not modify language preference', (
      tester,
    ) async {
      final bundle = _buildApp(
        poemRepository: mockPoemRepo,
        favouritesRepository: mockFavRepo,
        languagePreferencesRepository: mockLangRepo,
        themePreferencesRepository: mockThemeRepo,
        initialLanguage: PoemLanguage.english,
        initialPreference: ThemePreference.system,
      );

      await tester.pumpWidget(bundle.app);
      await tester.pump();

      // Change theme to dark
      bundle.themeCubit.changeTheme(ThemePreference.dark);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Language preference should still be English
      expect(bundle.langCubit.state.language, PoemLanguage.english);

      bundle.themeCubit.close();
      bundle.langCubit.close();
      bundle.favCubit.close();
      bundle.shareCubit.close();
    });

    testWidgets('theme change does not modify favourite IDs', (tester) async {
      when(
        () => mockFavRepo.getFavouritePoemIds(),
      ).thenAnswer((_) async => ['poem1']);

      final bundle = _buildApp(
        poemRepository: mockPoemRepo,
        favouritesRepository: mockFavRepo,
        languagePreferencesRepository: mockLangRepo,
        themePreferencesRepository: mockThemeRepo,
        initialLanguage: PoemLanguage.english,
        initialPreference: ThemePreference.system,
      );

      await tester.pumpWidget(bundle.app);
      await tester.pump();

      // Load favourites
      bundle.favCubit.loadFavourites();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Change theme
      bundle.themeCubit.changeTheme(ThemePreference.dark);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Favourites cubit should not have been affected
      expect(bundle.favCubit.state, isA<FavouritesLoaded>());
      final loaded = bundle.favCubit.state as FavouritesLoaded;
      expect(loaded.favouriteIds, contains('poem1'));

      bundle.themeCubit.close();
      bundle.langCubit.close();
      bundle.favCubit.close();
      bundle.shareCubit.close();
    });

    testWidgets('theme change does not close PoemDetails route', (
      tester,
    ) async {
      // Use a taller viewport so the button is visible above the NavigationBar.
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final bundle = _buildApp(
        poemRepository: mockPoemRepo,
        favouritesRepository: mockFavRepo,
        languagePreferencesRepository: mockLangRepo,
        themePreferencesRepository: mockThemeRepo,
        initialLanguage: PoemLanguage.english,
        initialPreference: ThemePreference.system,
      );

      await tester.pumpWidget(bundle.app);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Navigate to poem details
      await tester.tap(find.text('Read in focus mode'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Poem'), findsOneWidget);

      // Change theme
      bundle.themeCubit.changeTheme(ThemePreference.dark);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Poem details should still be visible
      expect(find.text('Poem'), findsOneWidget);

      bundle.themeCubit.close();
      bundle.langCubit.close();
      bundle.favCubit.close();
      bundle.shareCubit.close();
    });

    testWidgets('theme change does not reset NavigationBar branch', (
      tester,
    ) async {
      final bundle = _buildApp(
        poemRepository: mockPoemRepo,
        favouritesRepository: mockFavRepo,
        languagePreferencesRepository: mockLangRepo,
        themePreferencesRepository: mockThemeRepo,
        initialLanguage: PoemLanguage.english,
        initialPreference: ThemePreference.system,
      );

      await tester.pumpWidget(bundle.app);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Start on Today tab, navigate to Settings
      // Use the GoRouter to navigate to settings
      appRouter.go('/settings');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Appearance'), findsOneWidget);

      // Change theme
      bundle.themeCubit.changeTheme(ThemePreference.dark);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should still be on Settings tab
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text("Today's poem"), findsNothing);

      bundle.themeCubit.close();
      bundle.langCubit.close();
      bundle.favCubit.close();
      bundle.shareCubit.close();
    });
  });
}
