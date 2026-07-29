import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:daily_stanza/app.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/daily_poem_result.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/poem.dart';
import 'package:daily_stanza/features/daily_poem/domain/repository/poem_repository.dart';
import 'package:daily_stanza/features/favourites/domain/repository/favourites_repository.dart';
import 'package:daily_stanza/features/favourites/presentation/cubit/favourites_cubit.dart';
import 'package:daily_stanza/features/settings/domain/model/poem_language.dart';
import 'package:daily_stanza/features/settings/domain/repository/language_preferences_repository.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/language_preferences_cubit.dart';

class MockPoemRepository extends Mock implements PoemRepository {}

class MockFavouritesRepository extends Mock implements FavouritesRepository {}

class MockLanguagePreferencesRepository extends Mock
    implements LanguagePreferencesRepository {}

void main() {
  testWidgets('App renders without error', (tester) async {
    final mockPoemRepo = MockPoemRepository();
    final mockFavRepo = MockFavouritesRepository();
    final mockLangRepo = MockLanguagePreferencesRepository();
    when(
      () => mockPoemRepo.getDailyPoem(
        date: any(named: 'date'),
        languageCode: any(named: 'languageCode'),
      ),
    ).thenAnswer(
      (_) async => const DailyPoemResult(
        poem: Poem(
          id: 'test',
          title: 'Test',
          author: 'Author',
          languageCode: 'en',
          countryCode: 'US',
          content: 'Content',
          sourceName: 'Source',
          sourceUrl: 'https://example.com',
          rightsStatus: 'public_domain',
        ),
        isFromCache: false,
      ),
    );
    when(() => mockFavRepo.getFavouritePoemIds()).thenAnswer((_) async => []);
    when(
      () => mockLangRepo.getPreferredLanguage(),
    ).thenAnswer((_) async => PoemLanguage.english);

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<PoemRepository>.value(value: mockPoemRepo),
          RepositoryProvider<FavouritesRepository>.value(value: mockFavRepo),
          RepositoryProvider<LanguagePreferencesRepository>.value(
            value: mockLangRepo,
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<FavouritesCubit>(
              create: (_) => FavouritesCubit(
                favouritesRepository: mockFavRepo,
                poemRepository: mockPoemRepo,
              )..loadFavourites(),
            ),
            BlocProvider<LanguagePreferencesCubit>(
              create: (_) => LanguagePreferencesCubit(
                repository: mockLangRepo,
                initialLanguage: PoemLanguage.english,
              ),
            ),
          ],
          child: App(scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(App), findsOneWidget);
  });
}
