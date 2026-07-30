import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:daily_stanza/core/config/app_links.dart';
import 'package:daily_stanza/features/settings/domain/model/app_info.dart';
import 'package:daily_stanza/features/settings/domain/model/poem_language.dart';
import 'package:daily_stanza/features/settings/domain/model/theme_preference.dart';
import 'package:daily_stanza/features/settings/domain/service/external_link_launcher.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/app_information_cubit.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/app_information_state.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/language_preferences_cubit.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/language_preferences_state.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/theme_preferences_cubit.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/theme_preferences_state.dart';
import 'package:daily_stanza/features/settings/presentation/view/settings_view.dart';

class MockLanguagePreferencesCubit
    extends MockBloc<LanguagePreferencesCubit, LanguagePreferencesState>
    implements LanguagePreferencesCubit {}

class MockThemePreferencesCubit
    extends MockBloc<ThemePreferencesCubit, ThemePreferencesState>
    implements ThemePreferencesCubit {}

class MockAppInformationCubit
    extends MockBloc<AppInformationCubit, AppInformationState>
    implements AppInformationCubit {}

class MockExternalLinkLauncher extends Mock implements ExternalLinkLauncher {}

Widget _buildApp({
  required MockLanguagePreferencesCubit langCubit,
  required MockThemePreferencesCubit themeCubit,
  MockAppInformationCubit? appInfoCubit,
  MockExternalLinkLauncher? launcher,
}) {
  final appCubit = appInfoCubit ?? MockAppInformationCubit();
  final linkLauncher = launcher ?? MockExternalLinkLauncher();
  if (appInfoCubit == null) {
    whenListen(
      appCubit,
      const Stream<AppInformationState>.empty(),
      initialState: const AppInformationState(),
    );
  }
  return MaterialApp(
    home: MultiBlocProvider(
      providers: [
        BlocProvider<LanguagePreferencesCubit>.value(value: langCubit),
        BlocProvider<ThemePreferencesCubit>.value(value: themeCubit),
        BlocProvider<AppInformationCubit>.value(value: appCubit),
      ],
      child: RepositoryProvider<ExternalLinkLauncher>.value(
        value: linkLauncher,
        child: const SettingsView(),
      ),
    ),
  );
}

void main() {
  late MockLanguagePreferencesCubit mockLangCubit;
  late MockThemePreferencesCubit mockThemeCubit;

  setUpAll(() {
    registerFallbackValue(PoemLanguage.english);
    registerFallbackValue(PoemLanguage.polish);
    registerFallbackValue(ThemePreference.system);
    registerFallbackValue(ThemePreference.light);
    registerFallbackValue(ThemePreference.dark);
    registerFallbackValue(Uri());
  });

  setUp(() {
    mockLangCubit = MockLanguagePreferencesCubit();
    mockThemeCubit = MockThemePreferencesCubit();
  });

  group('SettingsView', () {
    // --- Existing language preference tests (unchanged) ---

    testWidgets('Settings title', (tester) async {
      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.system,
        ),
      );

      await tester.pumpWidget(
        _buildApp(langCubit: mockLangCubit, themeCubit: mockThemeCubit),
      );
      await tester.pump();

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('Poem language title', (tester) async {
      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.system,
        ),
      );

      await tester.pumpWidget(
        _buildApp(langCubit: mockLangCubit, themeCubit: mockThemeCubit),
      );
      await tester.pump();

      expect(find.text('Poem language'), findsOneWidget);
    });

    testWidgets('Poem language description', (tester) async {
      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.system,
        ),
      );

      await tester.pumpWidget(
        _buildApp(langCubit: mockLangCubit, themeCubit: mockThemeCubit),
      );
      await tester.pump();

      expect(
        find.text('Choose the language used for the daily poem.'),
        findsOneWidget,
      );
    });

    testWidgets('English option', (tester) async {
      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.system,
        ),
      );

      await tester.pumpWidget(
        _buildApp(langCubit: mockLangCubit, themeCubit: mockThemeCubit),
      );
      await tester.pump();

      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('Polski option', (tester) async {
      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.system,
        ),
      );

      await tester.pumpWidget(
        _buildApp(langCubit: mockLangCubit, themeCubit: mockThemeCubit),
      );
      await tester.pump();

      expect(find.text('Polski'), findsOneWidget);
    });

    testWidgets('current language option selected', (tester) async {
      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.polish,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.system,
        ),
      );

      await tester.pumpWidget(
        _buildApp(langCubit: mockLangCubit, themeCubit: mockThemeCubit),
      );
      await tester.pump();

      final radioGroup = tester.widget<RadioGroup<PoemLanguage>>(
        find.byType(RadioGroup<PoemLanguage>),
      );
      expect(radioGroup.groupValue, PoemLanguage.polish);
    });

    testWidgets('tapping English calls changeLanguage(english)', (
      tester,
    ) async {
      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.polish,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.system,
        ),
      );
      when(() => mockLangCubit.changeLanguage(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        _buildApp(langCubit: mockLangCubit, themeCubit: mockThemeCubit),
      );
      await tester.pump();

      await tester.tap(
        find.widgetWithText(RadioListTile<PoemLanguage>, 'English'),
      );
      await tester.pump();

      verify(
        () => mockLangCubit.changeLanguage(PoemLanguage.english),
      ).called(1);
    });

    testWidgets('tapping Polish calls changeLanguage(polish)', (tester) async {
      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.system,
        ),
      );
      when(() => mockLangCubit.changeLanguage(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        _buildApp(langCubit: mockLangCubit, themeCubit: mockThemeCubit),
      );
      await tester.pump();

      await tester.tap(
        find.widgetWithText(RadioListTile<PoemLanguage>, 'Polski'),
      );
      await tester.pump();

      verify(() => mockLangCubit.changeLanguage(PoemLanguage.polish)).called(1);
    });

    testWidgets('language controls disabled while language isSaving', (
      tester,
    ) async {
      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
          isSaving: true,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.system,
        ),
      );

      await tester.pumpWidget(
        _buildApp(langCubit: mockLangCubit, themeCubit: mockThemeCubit),
      );
      await tester.pump();

      // The AbsorbPointer for the language section should be absorbing
      final absorbers = find.byWidgetPredicate(
        (widget) => widget is AbsorbPointer && widget.absorbing,
      );
      // There should be at least one absorbing AbsorbPointer (the language one)
      expect(absorbers, findsAtLeast(1));
    });

    testWidgets('language supporting local-storage text', (tester) async {
      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.system,
        ),
      );

      await tester.pumpWidget(
        _buildApp(langCubit: mockLangCubit, themeCubit: mockThemeCubit),
      );
      await tester.pump();

      expect(find.text('Saved on this device.'), findsAtLeast(1));
    });

    testWidgets('no overflow at 360x800', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.system,
        ),
      );

      await tester.pumpWidget(
        _buildApp(langCubit: mockLangCubit, themeCubit: mockThemeCubit),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('no overflow at 390x844', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.system,
        ),
      );

      await tester.pumpWidget(
        _buildApp(langCubit: mockLangCubit, themeCubit: mockThemeCubit),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('no overflow at 600x960', (tester) async {
      tester.view.physicalSize = const Size(600, 960);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.system,
        ),
      );

      await tester.pumpWidget(
        _buildApp(langCubit: mockLangCubit, themeCubit: mockThemeCubit),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('no overflow with increased text scale', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      tester.view.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.platformDispatcher.clearTextScaleFactorTestValue();
      });

      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.system,
        ),
      );

      await tester.pumpWidget(
        _buildApp(langCubit: mockLangCubit, themeCubit: mockThemeCubit),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    // --- New Appearance section tests ---

    testWidgets('Appearance section is visible', (tester) async {
      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.system,
        ),
      );

      await tester.pumpWidget(
        _buildApp(langCubit: mockLangCubit, themeCubit: mockThemeCubit),
      );
      await tester.pump();

      expect(find.text('Appearance'), findsOneWidget);
    });

    testWidgets('Appearance description is visible', (tester) async {
      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.system,
        ),
      );

      await tester.pumpWidget(
        _buildApp(langCubit: mockLangCubit, themeCubit: mockThemeCubit),
      );
      await tester.pump();

      expect(
        find.text('Choose how Daily Stanza looks on this device.'),
        findsOneWidget,
      );
    });

    testWidgets('System option is visible', (tester) async {
      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.system,
        ),
      );

      await tester.pumpWidget(
        _buildApp(langCubit: mockLangCubit, themeCubit: mockThemeCubit),
      );
      await tester.pump();

      expect(find.text('System'), findsOneWidget);
    });

    testWidgets('Light option is visible', (tester) async {
      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.system,
        ),
      );

      await tester.pumpWidget(
        _buildApp(langCubit: mockLangCubit, themeCubit: mockThemeCubit),
      );
      await tester.pump();

      expect(find.text('Light'), findsOneWidget);
    });

    testWidgets('Dark option is visible', (tester) async {
      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.system,
        ),
      );

      await tester.pumpWidget(
        _buildApp(langCubit: mockLangCubit, themeCubit: mockThemeCubit),
      );
      await tester.pump();

      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('correct theme option is selected', (tester) async {
      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.dark,
        ),
      );

      await tester.pumpWidget(
        _buildApp(langCubit: mockLangCubit, themeCubit: mockThemeCubit),
      );
      await tester.pump();

      final themeRadioGroup = tester.widget<RadioGroup<ThemePreference>>(
        find.byType(RadioGroup<ThemePreference>),
      );
      expect(themeRadioGroup.groupValue, ThemePreference.dark);
    });

    testWidgets('tapping System calls changeTheme(system)', (tester) async {
      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.light,
        ),
      );
      when(() => mockThemeCubit.changeTheme(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        _buildApp(langCubit: mockLangCubit, themeCubit: mockThemeCubit),
      );
      await tester.pump();

      await tester.tap(
        find.widgetWithText(RadioListTile<ThemePreference>, 'System'),
      );
      await tester.pump();

      verify(
        () => mockThemeCubit.changeTheme(ThemePreference.system),
      ).called(1);
    });

    testWidgets('tapping Light calls changeTheme(light)', (tester) async {
      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.system,
        ),
      );
      when(() => mockThemeCubit.changeTheme(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        _buildApp(langCubit: mockLangCubit, themeCubit: mockThemeCubit),
      );
      await tester.pump();

      await tester.tap(
        find.widgetWithText(RadioListTile<ThemePreference>, 'Light'),
      );
      await tester.pump();

      verify(() => mockThemeCubit.changeTheme(ThemePreference.light)).called(1);
    });

    testWidgets('tapping Dark calls changeTheme(dark)', (tester) async {
      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.system,
        ),
      );
      when(() => mockThemeCubit.changeTheme(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        _buildApp(langCubit: mockLangCubit, themeCubit: mockThemeCubit),
      );
      await tester.pump();

      await tester.tap(
        find.widgetWithText(RadioListTile<ThemePreference>, 'Dark'),
      );
      await tester.pump();

      verify(() => mockThemeCubit.changeTheme(ThemePreference.dark)).called(1);
    });

    testWidgets('theme controls disabled while theme isSaving', (tester) async {
      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.system,
          isSaving: true,
        ),
      );

      await tester.pumpWidget(
        _buildApp(langCubit: mockLangCubit, themeCubit: mockThemeCubit),
      );
      await tester.pump();

      // The AbsorbPointer wrapping the theme controls should be absorbing
      // Find all AbsorbPointer widgets that are absorbing
      final absorbers = find.byWidgetPredicate(
        (widget) => widget is AbsorbPointer && widget.absorbing,
      );
      // There should be at least one
      expect(absorbers, findsAtLeast(1));
    });

    testWidgets('language controls remain enabled while theme isSaving', (
      tester,
    ) async {
      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.system,
          isSaving: true,
        ),
      );

      await tester.pumpWidget(
        _buildApp(langCubit: mockLangCubit, themeCubit: mockThemeCubit),
      );
      await tester.pump();

      // Language section's AbsorbPointer should NOT be absorbing
      // Find the language RadioGroup and check its parent is not absorbing
      final langRadioGroup = find.byType(RadioGroup<PoemLanguage>);
      expect(langRadioGroup, findsOneWidget);

      // The parent AbsorbPointer of the language section should not be absorbing
      final absorbingParent = find.ancestor(
        of: langRadioGroup,
        matching: find.byType(AbsorbPointer),
      );
      final absorber = tester.widget<AbsorbPointer>(absorbingParent.first);
      expect(absorber.absorbing, isFalse);
    });

    testWidgets('theme controls remain enabled while language isSaving', (
      tester,
    ) async {
      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
          isSaving: true,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.system,
        ),
      );

      await tester.pumpWidget(
        _buildApp(langCubit: mockLangCubit, themeCubit: mockThemeCubit),
      );
      await tester.pump();

      // Theme section's AbsorbPointer should NOT be absorbing
      final themeRadioGroup = find.byType(RadioGroup<ThemePreference>);
      expect(themeRadioGroup, findsOneWidget);

      final absorbingParent = find.ancestor(
        of: themeRadioGroup,
        matching: find.byType(AbsorbPointer),
      );
      final absorber = tester.widget<AbsorbPointer>(absorbingParent.first);
      expect(absorber.absorbing, isFalse);
    });

    testWidgets('Appearance supporting text is visible', (tester) async {
      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.system,
        ),
      );

      await tester.pumpWidget(
        _buildApp(langCubit: mockLangCubit, themeCubit: mockThemeCubit),
      );
      await tester.pump();

      // There are two "Saved on this device." texts — one for language, one for theme
      expect(find.text('Saved on this device.'), findsAtLeast(2));
    });

    testWidgets('no unrelated settings appear', (tester) async {
      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.system,
        ),
      );

      await tester.pumpWidget(
        _buildApp(langCubit: mockLangCubit, themeCubit: mockThemeCubit),
      );
      await tester.pump();

      // No unrelated sections should appear
      expect(find.text('Notifications'), findsNothing);
      expect(find.text('Account'), findsNothing);
      expect(find.text('Subscription'), findsNothing);
    });

    // --- App information section tests ---

    testWidgets('App information section is visible', (tester) async {
      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.system,
        ),
      );
      final mockAppInfoCubit = MockAppInformationCubit();
      whenListen(
        mockAppInfoCubit,
        const Stream<AppInformationState>.empty(),
        initialState: const AppInformationState(),
      );

      await tester.pumpWidget(
        _buildApp(
          langCubit: mockLangCubit,
          themeCubit: mockThemeCubit,
          appInfoCubit: mockAppInfoCubit,
        ),
      );
      await tester.pump();

      expect(find.text('App information'), findsOneWidget);
    });

    testWidgets('Application name is rendered', (tester) async {
      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.system,
        ),
      );
      final mockAppInfoCubit = MockAppInformationCubit();
      whenListen(
        mockAppInfoCubit,
        const Stream<AppInformationState>.empty(),
        initialState: const AppInformationState(),
      );

      await tester.pumpWidget(
        _buildApp(
          langCubit: mockLangCubit,
          themeCubit: mockThemeCubit,
          appInfoCubit: mockAppInfoCubit,
        ),
      );
      await tester.pump();

      expect(find.text('Application name'), findsOneWidget);
      expect(find.text('Daily Stanza'), findsOneWidget);
    });

    testWidgets('version and build number are rendered', (tester) async {
      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.system,
        ),
      );
      final mockAppInfoCubit = MockAppInformationCubit();
      whenListen(
        mockAppInfoCubit,
        const Stream<AppInformationState>.empty(),
        initialState: const AppInformationState(
          appInfo: AppInfo(
            appName: 'Daily Stanza',
            version: '1.0.0',
            buildNumber: '1',
          ),
        ),
      );

      await tester.pumpWidget(
        _buildApp(
          langCubit: mockLangCubit,
          themeCubit: mockThemeCubit,
          appInfoCubit: mockAppInfoCubit,
        ),
      );
      await tester.pump();

      expect(find.text('Version'), findsOneWidget);
      expect(find.text('Version 1.0.0 (1)'), findsOneWidget);
    });

    testWidgets('tapping GitHub row requests the exact repository URI', (
      tester,
    ) async {
      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.system,
        ),
      );
      final mockAppInfoCubit = MockAppInformationCubit();
      whenListen(
        mockAppInfoCubit,
        const Stream<AppInformationState>.empty(),
        initialState: const AppInformationState(),
      );
      final mockLauncher = MockExternalLinkLauncher();
      when(() => mockLauncher.launchUrl(any())).thenAnswer((_) async => true);

      await tester.pumpWidget(
        _buildApp(
          langCubit: mockLangCubit,
          themeCubit: mockThemeCubit,
          appInfoCubit: mockAppInfoCubit,
          launcher: mockLauncher,
        ),
      );
      await tester.pump();

      await tester.tap(find.text('GitHub repository'));
      await tester.pump();

      verify(() => mockLauncher.launchUrl(AppLinks.githubRepository)).called(1);
    });

    testWidgets('tapping Privacy policy row requests the exact privacy URI', (
      tester,
    ) async {
      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.system,
        ),
      );
      final mockAppInfoCubit = MockAppInformationCubit();
      whenListen(
        mockAppInfoCubit,
        const Stream<AppInformationState>.empty(),
        initialState: const AppInformationState(),
      );
      final mockLauncher = MockExternalLinkLauncher();
      when(() => mockLauncher.launchUrl(any())).thenAnswer((_) async => true);

      await tester.pumpWidget(
        _buildApp(
          langCubit: mockLangCubit,
          themeCubit: mockThemeCubit,
          appInfoCubit: mockAppInfoCubit,
          launcher: mockLauncher,
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Privacy policy'));
      await tester.pump();

      verify(() => mockLauncher.launchUrl(AppLinks.privacyPolicy)).called(1);
    });

    testWidgets('launch failure does not crash and shows feedback', (
      tester,
    ) async {
      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.system,
        ),
      );
      final mockAppInfoCubit = MockAppInformationCubit();
      whenListen(
        mockAppInfoCubit,
        const Stream<AppInformationState>.empty(),
        initialState: const AppInformationState(),
      );
      final mockLauncher = MockExternalLinkLauncher();
      when(() => mockLauncher.launchUrl(any())).thenAnswer((_) async => false);

      await tester.pumpWidget(
        _buildApp(
          langCubit: mockLangCubit,
          themeCubit: mockThemeCubit,
          appInfoCubit: mockAppInfoCubit,
          launcher: mockLauncher,
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Privacy policy'));
      await tester.pump();

      expect(find.text('Could not open the link.'), findsOneWidget);
    });

    testWidgets('language controls remain functional after adding app info', (
      tester,
    ) async {
      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.polish,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.system,
        ),
      );
      final mockAppInfoCubit = MockAppInformationCubit();
      whenListen(
        mockAppInfoCubit,
        const Stream<AppInformationState>.empty(),
        initialState: const AppInformationState(),
      );
      when(() => mockLangCubit.changeLanguage(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        _buildApp(
          langCubit: mockLangCubit,
          themeCubit: mockThemeCubit,
          appInfoCubit: mockAppInfoCubit,
        ),
      );
      await tester.pump();

      await tester.tap(
        find.widgetWithText(RadioListTile<PoemLanguage>, 'English'),
      );
      await tester.pump();

      verify(
        () => mockLangCubit.changeLanguage(PoemLanguage.english),
      ).called(1);
    });

    testWidgets('theme controls remain functional after adding app info', (
      tester,
    ) async {
      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.light,
        ),
      );
      final mockAppInfoCubit = MockAppInformationCubit();
      whenListen(
        mockAppInfoCubit,
        const Stream<AppInformationState>.empty(),
        initialState: const AppInformationState(),
      );
      when(() => mockThemeCubit.changeTheme(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        _buildApp(
          langCubit: mockLangCubit,
          themeCubit: mockThemeCubit,
          appInfoCubit: mockAppInfoCubit,
        ),
      );
      await tester.pump();

      await tester.tap(
        find.widgetWithText(RadioListTile<ThemePreference>, 'System'),
      );
      await tester.pump();

      verify(
        () => mockThemeCubit.changeTheme(ThemePreference.system),
      ).called(1);
    });

    testWidgets('App information section renders without overflow at 360x800', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.system,
        ),
      );
      final mockAppInfoCubit = MockAppInformationCubit();
      whenListen(
        mockAppInfoCubit,
        const Stream<AppInformationState>.empty(),
        initialState: const AppInformationState(
          appInfo: AppInfo(
            appName: 'Daily Stanza',
            version: '1.0.0',
            buildNumber: '1',
          ),
        ),
      );

      await tester.pumpWidget(
        _buildApp(
          langCubit: mockLangCubit,
          themeCubit: mockThemeCubit,
          appInfoCubit: mockAppInfoCubit,
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'App information section renders without overflow with increased text scale',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        tester.view.platformDispatcher.textScaleFactorTestValue = 1.5;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.platformDispatcher.clearTextScaleFactorTestValue();
        });

        whenListen(
          mockLangCubit,
          const Stream<LanguagePreferencesState>.empty(),
          initialState: const LanguagePreferencesState(
            language: PoemLanguage.english,
          ),
        );
        whenListen(
          mockThemeCubit,
          const Stream<ThemePreferencesState>.empty(),
          initialState: const ThemePreferencesState(
            preference: ThemePreference.system,
          ),
        );
        final mockAppInfoCubit = MockAppInformationCubit();
        whenListen(
          mockAppInfoCubit,
          const Stream<AppInformationState>.empty(),
          initialState: const AppInformationState(
            appInfo: AppInfo(
              appName: 'Daily Stanza',
              version: '1.0.0',
              buildNumber: '1',
            ),
          ),
        );

        await tester.pumpWidget(
          _buildApp(
            langCubit: mockLangCubit,
            themeCubit: mockThemeCubit,
            appInfoCubit: mockAppInfoCubit,
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('GitHub row renders with light theme', (tester) async {
      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.light,
        ),
      );
      final mockAppInfoCubit = MockAppInformationCubit();
      whenListen(
        mockAppInfoCubit,
        const Stream<AppInformationState>.empty(),
        initialState: const AppInformationState(),
      );

      await tester.pumpWidget(
        _buildApp(
          langCubit: mockLangCubit,
          themeCubit: mockThemeCubit,
          appInfoCubit: mockAppInfoCubit,
        ),
      );
      await tester.pump();

      expect(find.text('GitHub repository'), findsOneWidget);
      expect(find.byIcon(Icons.open_in_new), findsAtLeast(2));
    });

    testWidgets('GitHub row renders with dark theme', (tester) async {
      whenListen(
        mockLangCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );
      whenListen(
        mockThemeCubit,
        const Stream<ThemePreferencesState>.empty(),
        initialState: const ThemePreferencesState(
          preference: ThemePreference.dark,
        ),
      );
      final mockAppInfoCubit = MockAppInformationCubit();
      whenListen(
        mockAppInfoCubit,
        const Stream<AppInformationState>.empty(),
        initialState: const AppInformationState(),
      );

      await tester.pumpWidget(
        _buildApp(
          langCubit: mockLangCubit,
          themeCubit: mockThemeCubit,
          appInfoCubit: mockAppInfoCubit,
        ),
      );
      await tester.pump();

      expect(find.text('GitHub repository'), findsOneWidget);
      expect(find.byIcon(Icons.open_in_new), findsAtLeast(2));
    });
  });
}
