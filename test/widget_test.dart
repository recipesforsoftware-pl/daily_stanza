import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:daily_stanza/app.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/daily_poem_result.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/poem.dart';
import 'package:daily_stanza/features/daily_poem/domain/repository/poem_repository.dart';

class MockPoemRepository extends Mock implements PoemRepository {}

void main() {
  testWidgets('App renders without error', (tester) async {
    final mockRepo = MockPoemRepository();
    when(
      () => mockRepo.getDailyPoem(
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

    await tester.pumpWidget(
      RepositoryProvider<PoemRepository>.value(
        value: mockRepo,
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(App), findsOneWidget);
  });
}
