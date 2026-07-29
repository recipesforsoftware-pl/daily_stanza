import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:daily_stanza/features/daily_poem/domain/failure/daily_poem_failure.dart'
    as domain;
import 'package:daily_stanza/features/daily_poem/domain/model/daily_poem_result.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/poem.dart';
import 'package:daily_stanza/features/daily_poem/domain/repository/poem_repository.dart';
import 'package:daily_stanza/features/daily_poem/presentation/bloc/daily_poem_bloc.dart';
import 'package:daily_stanza/features/daily_poem/presentation/bloc/daily_poem_event.dart';
import 'package:daily_stanza/features/daily_poem/presentation/view/today_view.dart';
import 'package:daily_stanza/features/favourites/presentation/cubit/favourites_cubit.dart';
import 'package:daily_stanza/features/favourites/presentation/cubit/favourites_state.dart';
import 'package:daily_stanza/features/settings/domain/model/poem_language.dart';
import 'package:daily_stanza/features/settings/domain/repository/language_preferences_repository.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/language_preferences_cubit.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/language_preferences_state.dart';
import 'package:daily_stanza/features/share_poem/domain/model/poem_share_result.dart';
import 'package:daily_stanza/features/share_poem/domain/service/poem_share_service.dart';
import 'package:daily_stanza/features/share_poem/presentation/cubit/poem_share_cubit.dart';

class MockPoemRepository extends Mock implements PoemRepository {}

class MockLanguagePreferencesRepository extends Mock
    implements LanguagePreferencesRepository {}

class MockFavouritesCubit extends Mock implements FavouritesCubit {}

class MockPoemShareService extends Mock implements PoemShareService {}

final _testDate = DateTime(2026, 7, 29);

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
  required DailyPoemBloc dailyPoemBloc,
  required LanguagePreferencesCubit languageCubit,
  MockFavouritesCubit? favouritesCubit,
  PoemShareCubit? shareCubit,
  DateTime Function()? now,
}) {
  final favCubit = favouritesCubit ?? _createDefaultFavCubit();
  final shareCubitValue = shareCubit ?? _createDefaultShareCubit();
  return MaterialApp(
    home: MultiBlocProvider(
      providers: [
        BlocProvider<DailyPoemBloc>.value(value: dailyPoemBloc),
        BlocProvider<LanguagePreferencesCubit>.value(value: languageCubit),
        BlocProvider<FavouritesCubit>.value(value: favCubit),
        BlocProvider<PoemShareCubit>.value(value: shareCubitValue),
      ],
      child: TodayView(now: now),
    ),
  );
}

MockFavouritesCubit _createDefaultFavCubit() {
  final cubit = MockFavouritesCubit();
  when(
    () => cubit.state,
  ).thenReturn(const FavouritesLoaded(poems: [], favouriteIds: {}));
  when(
    () => cubit.stream,
  ).thenAnswer((_) => const Stream<FavouritesState>.empty());
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
  late MockPoemRepository mockPoemRepo;
  late MockLanguagePreferencesRepository mockLangRepo;

  setUp(() {
    mockPoemRepo = MockPoemRepository();
    mockLangRepo = MockLanguagePreferencesRepository();
  });

  setUpAll(() {
    registerFallbackValue(_testDate);
    registerFallbackValue(PoemLanguage.english);
    registerFallbackValue(PoemLanguage.polish);
    registerFallbackValue(PoemShareResult.completed);
  });

  group('Today language integration', () {
    testWidgets('initial request uses English when English is active', (
      tester,
    ) async {
      when(
        () => mockPoemRepo.getDailyPoem(
          date: any(named: 'date'),
          languageCode: any(named: 'languageCode'),
        ),
      ).thenAnswer(
        (_) async => const DailyPoemResult(poem: _testPoem, isFromCache: false),
      );

      final langCubit = LanguagePreferencesCubit(
        repository: mockLangRepo,
        initialLanguage: PoemLanguage.english,
      );

      await tester.pumpWidget(
        _buildApp(
          dailyPoemBloc: DailyPoemBloc(repository: mockPoemRepo),
          languageCubit: langCubit,
          now: () => _testDate,
        ),
      );
      await tester.pump();

      verify(
        () => mockPoemRepo.getDailyPoem(date: _testDate, languageCode: 'en'),
      ).called(1);
      await langCubit.close();
    });

    testWidgets('initial request uses Polish when Polish is active', (
      tester,
    ) async {
      when(
        () => mockPoemRepo.getDailyPoem(
          date: any(named: 'date'),
          languageCode: any(named: 'languageCode'),
        ),
      ).thenAnswer(
        (_) async => const DailyPoemResult(poem: _testPoem, isFromCache: false),
      );

      final langCubit = LanguagePreferencesCubit(
        repository: mockLangRepo,
        initialLanguage: PoemLanguage.polish,
      );

      await tester.pumpWidget(
        _buildApp(
          dailyPoemBloc: DailyPoemBloc(repository: mockPoemRepo),
          languageCubit: langCubit,
          now: () => _testDate,
        ),
      );
      await tester.pump();

      verify(
        () => mockPoemRepo.getDailyPoem(date: _testDate, languageCode: 'pl'),
      ).called(1);
      await langCubit.close();
    });

    testWidgets('initial request occurs exactly once', (tester) async {
      when(
        () => mockPoemRepo.getDailyPoem(
          date: any(named: 'date'),
          languageCode: any(named: 'languageCode'),
        ),
      ).thenAnswer(
        (_) async => const DailyPoemResult(poem: _testPoem, isFromCache: false),
      );

      final langCubit = LanguagePreferencesCubit(
        repository: mockLangRepo,
        initialLanguage: PoemLanguage.english,
      );

      await tester.pumpWidget(
        _buildApp(
          dailyPoemBloc: DailyPoemBloc(repository: mockPoemRepo),
          languageCubit: langCubit,
          now: () => _testDate,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      verify(
        () => mockPoemRepo.getDailyPoem(date: _testDate, languageCode: 'en'),
      ).called(1);
      await langCubit.close();
    });

    testWidgets('successful English-to-Polish change requests pl', (
      tester,
    ) async {
      final requestedCodes = <String>[];
      when(
        () => mockPoemRepo.getDailyPoem(
          date: any(named: 'date'),
          languageCode: any(named: 'languageCode'),
        ),
      ).thenAnswer((invocation) async {
        requestedCodes.add(invocation.namedArguments[#languageCode] as String);
        return const DailyPoemResult(poem: _testPoem, isFromCache: false);
      });
      when(
        () => mockLangRepo.setPreferredLanguage(any()),
      ).thenAnswer((_) async {});

      final langCubit = LanguagePreferencesCubit(
        repository: mockLangRepo,
        initialLanguage: PoemLanguage.english,
      );

      await tester.pumpWidget(
        _buildApp(
          dailyPoemBloc: DailyPoemBloc(repository: mockPoemRepo),
          languageCubit: langCubit,
          now: () => _testDate,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      await langCubit.changeLanguage(PoemLanguage.polish);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(requestedCodes, contains('pl'));
      await langCubit.close();
    });

    testWidgets('successful Polish-to-English change requests en', (
      tester,
    ) async {
      final requestedCodes = <String>[];
      when(
        () => mockPoemRepo.getDailyPoem(
          date: any(named: 'date'),
          languageCode: any(named: 'languageCode'),
        ),
      ).thenAnswer((invocation) async {
        requestedCodes.add(invocation.namedArguments[#languageCode] as String);
        return const DailyPoemResult(poem: _testPoem, isFromCache: false);
      });
      when(
        () => mockLangRepo.setPreferredLanguage(any()),
      ).thenAnswer((_) async {});

      final langCubit = LanguagePreferencesCubit(
        repository: mockLangRepo,
        initialLanguage: PoemLanguage.polish,
      );

      await tester.pumpWidget(
        _buildApp(
          dailyPoemBloc: DailyPoemBloc(repository: mockPoemRepo),
          languageCubit: langCubit,
          now: () => _testDate,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      await langCubit.changeLanguage(PoemLanguage.english);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(requestedCodes, contains('en'));
      await langCubit.close();
    });

    testWidgets('isSaving-only state change does not request a poem', (
      tester,
    ) async {
      var callCount = 0;
      when(
        () => mockPoemRepo.getDailyPoem(
          date: any(named: 'date'),
          languageCode: any(named: 'languageCode'),
        ),
      ).thenAnswer((_) async {
        callCount++;
        return const DailyPoemResult(poem: _testPoem, isFromCache: false);
      });

      final langCubit = LanguagePreferencesCubit(
        repository: mockLangRepo,
        initialLanguage: PoemLanguage.english,
      );

      await tester.pumpWidget(
        _buildApp(
          dailyPoemBloc: DailyPoemBloc(repository: mockPoemRepo),
          languageCubit: langCubit,
          now: () => _testDate,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Emit a saving-only state directly (no language change)
      langCubit.emit(
        const LanguagePreferencesState(
          language: PoemLanguage.english,
          isSaving: true,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(callCount, 1);
      await langCubit.close();
    });

    testWidgets('mutationError-only state change does not request a poem', (
      tester,
    ) async {
      var callCount = 0;
      when(
        () => mockPoemRepo.getDailyPoem(
          date: any(named: 'date'),
          languageCode: any(named: 'languageCode'),
        ),
      ).thenAnswer((_) async {
        callCount++;
        return const DailyPoemResult(poem: _testPoem, isFromCache: false);
      });

      final langCubit = LanguagePreferencesCubit(
        repository: mockLangRepo,
        initialLanguage: PoemLanguage.english,
      );

      await tester.pumpWidget(
        _buildApp(
          dailyPoemBloc: DailyPoemBloc(repository: mockPoemRepo),
          languageCubit: langCubit,
          now: () => _testDate,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      langCubit.emit(
        const LanguagePreferencesState(
          language: PoemLanguage.english,
          mutationError: 'Some error',
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(callCount, 1);
      await langCubit.close();
    });

    testWidgets('failed preference save does not request a poem', (
      tester,
    ) async {
      var callCount = 0;
      when(
        () => mockPoemRepo.getDailyPoem(
          date: any(named: 'date'),
          languageCode: any(named: 'languageCode'),
        ),
      ).thenAnswer((_) async {
        callCount++;
        return const DailyPoemResult(poem: _testPoem, isFromCache: false);
      });
      when(
        () => mockLangRepo.setPreferredLanguage(any()),
      ).thenThrow(Exception('fail'));

      final langCubit = LanguagePreferencesCubit(
        repository: mockLangRepo,
        initialLanguage: PoemLanguage.english,
      );

      await tester.pumpWidget(
        _buildApp(
          dailyPoemBloc: DailyPoemBloc(repository: mockPoemRepo),
          languageCubit: langCubit,
          now: () => _testDate,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      await langCubit.changeLanguage(PoemLanguage.polish);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Only 1 call (initial), no request for failed save
      expect(callCount, 1);
      await langCubit.close();
    });

    testWidgets('selecting the same language does not request a poem', (
      tester,
    ) async {
      var callCount = 0;
      when(
        () => mockPoemRepo.getDailyPoem(
          date: any(named: 'date'),
          languageCode: any(named: 'languageCode'),
        ),
      ).thenAnswer((_) async {
        callCount++;
        return const DailyPoemResult(poem: _testPoem, isFromCache: false);
      });

      final langCubit = LanguagePreferencesCubit(
        repository: mockLangRepo,
        initialLanguage: PoemLanguage.english,
      );

      await tester.pumpWidget(
        _buildApp(
          dailyPoemBloc: DailyPoemBloc(repository: mockPoemRepo),
          languageCubit: langCubit,
          now: () => _testDate,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      await langCubit.changeLanguage(PoemLanguage.english);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(callCount, 1);
      await langCubit.close();
    });

    testWidgets('widget rebuild does not duplicate the initial request', (
      tester,
    ) async {
      var callCount = 0;
      when(
        () => mockPoemRepo.getDailyPoem(
          date: any(named: 'date'),
          languageCode: any(named: 'languageCode'),
        ),
      ).thenAnswer((_) async {
        callCount++;
        return const DailyPoemResult(poem: _testPoem, isFromCache: false);
      });

      final langCubit = LanguagePreferencesCubit(
        repository: mockLangRepo,
        initialLanguage: PoemLanguage.english,
      );

      await tester.pumpWidget(
        _buildApp(
          dailyPoemBloc: DailyPoemBloc(repository: mockPoemRepo),
          languageCubit: langCubit,
          now: () => _testDate,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Rebuild by pump
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(callCount, 1);
      await langCubit.close();
    });

    testWidgets('tab switching does not duplicate the request', (tester) async {
      var callCount = 0;
      when(
        () => mockPoemRepo.getDailyPoem(
          date: any(named: 'date'),
          languageCode: any(named: 'languageCode'),
        ),
      ).thenAnswer((_) async {
        callCount++;
        return const DailyPoemResult(poem: _testPoem, isFromCache: false);
      });

      final langCubit = LanguagePreferencesCubit(
        repository: mockLangRepo,
        initialLanguage: PoemLanguage.english,
      );

      await tester.pumpWidget(
        _buildApp(
          dailyPoemBloc: DailyPoemBloc(repository: mockPoemRepo),
          languageCubit: langCubit,
          now: () => _testDate,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Rebuild (simulates tab switching)
      await tester.pumpWidget(
        _buildApp(
          dailyPoemBloc: DailyPoemBloc(repository: mockPoemRepo),
          languageCubit: langCubit,
          now: () => _testDate,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(callCount, 1);
      await langCubit.close();
    });

    testWidgets('retry uses the last requested language', (tester) async {
      final requestedLanguages = <String>[];
      when(
        () => mockPoemRepo.getDailyPoem(
          date: any(named: 'date'),
          languageCode: any(named: 'languageCode'),
        ),
      ).thenAnswer((invocation) async {
        requestedLanguages.add(
          invocation.namedArguments[#languageCode] as String,
        );
        throw const domain.NetworkFailure();
      });

      final bloc = DailyPoemBloc(repository: mockPoemRepo);
      addTearDown(() => bloc.close());

      // Request 'en'
      bloc.add(DailyPoemRequested(date: _testDate, languageCode: 'en'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Request 'pl'
      bloc.add(DailyPoemRequested(date: _testDate, languageCode: 'pl'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Retry should use 'pl' (last requested)
      bloc.add(const DailyPoemRetryRequested());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(requestedLanguages.where((l) => l == 'pl').length, 2);
    });
  });
}
