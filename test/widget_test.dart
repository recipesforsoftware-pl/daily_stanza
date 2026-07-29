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

class MockPoemRepository extends Mock implements PoemRepository {}

class MockFavouritesRepository extends Mock implements FavouritesRepository {}

void main() {
  testWidgets('App renders without error', (tester) async {
    final mockPoemRepo = MockPoemRepository();
    final mockFavRepo = MockFavouritesRepository();
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

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<PoemRepository>.value(value: mockPoemRepo),
          RepositoryProvider<FavouritesRepository>.value(value: mockFavRepo),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<FavouritesCubit>(
              create: (_) => FavouritesCubit(
                favouritesRepository: mockFavRepo,
                poemRepository: mockPoemRepo,
              )..loadFavourites(),
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
