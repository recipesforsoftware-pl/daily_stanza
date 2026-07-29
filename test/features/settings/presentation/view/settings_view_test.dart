import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:daily_stanza/features/settings/domain/model/poem_language.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/language_preferences_cubit.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/language_preferences_state.dart';
import 'package:daily_stanza/features/settings/presentation/view/settings_view.dart';

class MockLanguagePreferencesCubit
    extends MockBloc<LanguagePreferencesCubit, LanguagePreferencesState>
    implements LanguagePreferencesCubit {}

Widget _buildApp(MockLanguagePreferencesCubit cubit) {
  return MaterialApp(
    home: BlocProvider<LanguagePreferencesCubit>.value(
      value: cubit,
      child: const SettingsView(),
    ),
  );
}

void main() {
  late MockLanguagePreferencesCubit mockCubit;

  setUpAll(() {
    registerFallbackValue(PoemLanguage.english);
    registerFallbackValue(PoemLanguage.polish);
  });

  setUp(() {
    mockCubit = MockLanguagePreferencesCubit();
  });

  group('SettingsView', () {
    testWidgets('Settings title', (tester) async {
      whenListen(
        mockCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );

      await tester.pumpWidget(_buildApp(mockCubit));
      await tester.pump();

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('Poem language title', (tester) async {
      whenListen(
        mockCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );

      await tester.pumpWidget(_buildApp(mockCubit));
      await tester.pump();

      expect(find.text('Poem language'), findsOneWidget);
    });

    testWidgets('description', (tester) async {
      whenListen(
        mockCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );

      await tester.pumpWidget(_buildApp(mockCubit));
      await tester.pump();

      expect(
        find.text('Choose the language used for the daily poem.'),
        findsOneWidget,
      );
    });

    testWidgets('English option', (tester) async {
      whenListen(
        mockCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );

      await tester.pumpWidget(_buildApp(mockCubit));
      await tester.pump();

      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('Polski option', (tester) async {
      whenListen(
        mockCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );

      await tester.pumpWidget(_buildApp(mockCubit));
      await tester.pump();

      expect(find.text('Polski'), findsOneWidget);
    });

    testWidgets('current option selected', (tester) async {
      whenListen(
        mockCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.polish,
        ),
      );

      await tester.pumpWidget(_buildApp(mockCubit));
      await tester.pump();

      // RadioGroup should have groupValue = Polish
      final radioGroup = tester.widget<RadioGroup<PoemLanguage>>(
        find.byType(RadioGroup<PoemLanguage>),
      );
      expect(radioGroup.groupValue, PoemLanguage.polish);
    });

    testWidgets('tapping English calls changeLanguage(english)', (
      tester,
    ) async {
      whenListen(
        mockCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.polish,
        ),
      );
      when(() => mockCubit.changeLanguage(any())).thenAnswer((_) async {});

      await tester.pumpWidget(_buildApp(mockCubit));
      await tester.pump();

      await tester.tap(
        find.widgetWithText(RadioListTile<PoemLanguage>, 'English'),
      );
      await tester.pump();

      verify(() => mockCubit.changeLanguage(PoemLanguage.english)).called(1);
    });

    testWidgets('tapping Polish calls changeLanguage(polish)', (tester) async {
      whenListen(
        mockCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );
      when(() => mockCubit.changeLanguage(any())).thenAnswer((_) async {});

      await tester.pumpWidget(_buildApp(mockCubit));
      await tester.pump();

      await tester.tap(
        find.widgetWithText(RadioListTile<PoemLanguage>, 'Polski'),
      );
      await tester.pump();

      verify(() => mockCubit.changeLanguage(PoemLanguage.polish)).called(1);
    });

    testWidgets('controls disabled while saving', (tester) async {
      whenListen(
        mockCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
          isSaving: true,
        ),
      );

      await tester.pumpWidget(_buildApp(mockCubit));
      await tester.pump();

      // AbsorbPointer should be absorbing when isSaving is true
      // Scope to the AbsorbPointer that has absorbing enabled.
      final absorber = tester.widget<AbsorbPointer>(
        find.byWidgetPredicate(
          (widget) => widget is AbsorbPointer && widget.absorbing,
        ),
      );
      expect(absorber.absorbing, isTrue);
    });

    testWidgets('supporting local-storage text', (tester) async {
      whenListen(
        mockCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );

      await tester.pumpWidget(_buildApp(mockCubit));
      await tester.pump();

      expect(find.text('Saved on this device.'), findsOneWidget);
    });

    testWidgets('no overflow at 360x800', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      whenListen(
        mockCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );

      await tester.pumpWidget(_buildApp(mockCubit));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('no overflow at 600x960', (tester) async {
      tester.view.physicalSize = const Size(600, 960);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      whenListen(
        mockCubit,
        const Stream<LanguagePreferencesState>.empty(),
        initialState: const LanguagePreferencesState(
          language: PoemLanguage.english,
        ),
      );

      await tester.pumpWidget(_buildApp(mockCubit));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
