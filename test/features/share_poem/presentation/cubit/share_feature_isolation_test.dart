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
import 'package:daily_stanza/features/settings/domain/model/poem_language.dart';
import 'package:daily_stanza/features/settings/domain/model/theme_preference.dart';
import 'package:daily_stanza/features/settings/domain/repository/language_preferences_repository.dart';
import 'package:daily_stanza/features/settings/domain/repository/theme_preferences_repository.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/language_preferences_cubit.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/theme_preferences_cubit.dart';
import 'package:share_plus/share_plus.dart' show ShareResult, ShareResultStatus;
import 'package:daily_stanza/features/share_poem/application/poem_share_text_builder.dart';
import 'package:daily_stanza/features/share_poem/data/service/share_plus_poem_share_service.dart';
import 'package:daily_stanza/features/share_poem/presentation/cubit/poem_share_cubit.dart';

class _MockPoemRepository extends Mock implements PoemRepository {}

class _MockFavouritesRepository extends Mock implements FavouritesRepository {}

class _MockLanguagePreferencesRepository extends Mock
    implements LanguagePreferencesRepository {}

class _MockThemePreferencesRepository extends Mock
    implements ThemePreferencesRepository {}

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
  // Use share_plus adapter with a mock invoker to prevent real platform calls.
  final shareService = SharePlusPoemShareService(
    shareInvoker: (_) async => const ShareResult('', ShareResultStatus.success),
  );
  final shareCubit = PoemShareCubit(
    shareService: shareService,
    textBuilder: const PoemShareTextBuilder(),
  );
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
    ],
    child: MultiBlocProvider(
      providers: [
        BlocProvider<FavouritesCubit>.value(value: favCubit),
        BlocProvider<LanguagePreferencesCubit>.value(value: langCubit),
        BlocProvider<ThemePreferencesCubit>.value(value: themeCubit),
      ],
      child: App(
        scaffoldMessengerKey: scaffoldMessengerKey,
        shareService: shareService,
      ),
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

  group('Share feature isolation', () {
    testWidgets('sharing does not dispatch DailyPoemRequested', (tester) async {
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

      // Find and tap the share button on Today
      final shareButtons = find.text('Share poem');
      if (shareButtons.evaluate().isNotEmpty) {
        await tester.tap(shareButtons.first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      }

      // PoemRepository should only have been called once (from initState)
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

    testWidgets('sharing does not change favourite IDs', (tester) async {
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

      // Get initial favourite IDs
      final initialFavIds = bundle.favCubit.isFavourite('poem1');

      // Trigger share (share service is injected with a mock that returns success)
      bundle.shareCubit.sharePoem(_testPoem);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Favourite state should be unchanged
      expect(bundle.favCubit.isFavourite('poem1'), initialFavIds);

      bundle.themeCubit.close();
      bundle.langCubit.close();
      bundle.favCubit.close();
      bundle.shareCubit.close();
    });

    testWidgets('sharing does not change language preference', (tester) async {
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

      bundle.shareCubit.sharePoem(_testPoem);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(bundle.langCubit.state.language, PoemLanguage.english);

      bundle.themeCubit.close();
      bundle.langCubit.close();
      bundle.favCubit.close();
      bundle.shareCubit.close();
    });

    testWidgets('sharing does not change theme preference', (tester) async {
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

      bundle.shareCubit.sharePoem(_testPoem);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(bundle.themeCubit.state.preference, ThemePreference.system);

      bundle.themeCubit.close();
      bundle.langCubit.close();
      bundle.favCubit.close();
      bundle.shareCubit.close();
    });

    testWidgets('sharing does not close PoemDetails route', (tester) async {
      // Use a taller viewport so the "Read in focus mode" button is visible
      // above the NavigationBar.
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

      // Trigger share from poem details
      bundle.shareCubit.sharePoem(_testPoem);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Poem details should still be visible
      expect(find.text('Poem'), findsOneWidget);

      bundle.themeCubit.close();
      bundle.langCubit.close();
      bundle.favCubit.close();
      bundle.shareCubit.close();
    });

    testWidgets('appRouter remains the same instance', (tester) async {
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

      final routerBefore = appRouter;
      bundle.shareCubit.sharePoem(_testPoem);
      await tester.pump();
      final routerAfter = appRouter;

      expect(routerBefore, same(routerAfter));

      bundle.themeCubit.close();
      bundle.langCubit.close();
      bundle.favCubit.close();
      bundle.shareCubit.close();
    });
  });
}
