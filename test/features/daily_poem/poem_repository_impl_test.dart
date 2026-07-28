import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daily_stanza/features/daily_poem/data/datasource/firestore_poem_data_source.dart';
import 'package:daily_stanza/features/daily_poem/data/repository/poem_repository_impl.dart';
import 'package:daily_stanza/features/daily_poem/domain/failure/daily_poem_failure.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/daily_poem_result.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late PoemRepositoryImpl repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = PoemRepositoryImpl(
      dataSource: FirestorePoemDataSource(firestore: fakeFirestore),
    );
  });

  setUp(() async {
    // Seed valid poem.
    await fakeFirestore.collection('poems').doc('poem1').set({
      'title': 'The Road Not Taken',
      'author': 'Robert Frost',
      'languageCode': 'en',
      'countryCode': 'US',
      'content': 'Two roads diverged in a yellow wood...',
      'sourceName': 'Mountain Interval',
      'sourceUrl': 'https://gutenberg.org',
      'rightsStatus': 'public_domain',
      'isApproved': true,
    });

    // Seed valid daily assignment.
    await fakeFirestore.collection('daily_poems').doc('en_20260728').set({
      'date': '2026-07-28',
      'languageCode': 'en',
      'poemId': 'poem1',
      'isPublished': true,
    });
  });

  group('getDailyPoem', () {
    test('returns DailyPoemResult for valid assignment', () async {
      final result = await repository.getDailyPoem(
        date: DateTime(2026, 7, 28),
        languageCode: 'en',
      );

      expect(result, isA<DailyPoemResult>());
      expect(result.poem.id, 'poem1');
      expect(result.poem.title, 'The Road Not Taken');
      expect(result.isFromCache, isA<bool>());
    });

    test('cache metadata is preserved', () async {
      final result = await repository.getDailyPoem(
        date: DateTime(2026, 7, 28),
        languageCode: 'en',
      );

      // fake_cloud_firestore returns isFromCache: false by default.
      expect(result.isFromCache, false);
    });

    test('throws DailyPoemNotFoundFailure for missing assignment', () {
      expect(
        () => repository.getDailyPoem(
          date: DateTime(2099, 1, 1),
          languageCode: 'en',
        ),
        throwsA(isA<DailyPoemNotFoundFailure>()),
      );
    });

    test('throws InvalidPoemDataFailure for unapproved poem', () async {
      await fakeFirestore.collection('poems').doc('unapproved').set({
        'title': 'Unapproved',
        'author': 'Nobody',
        'languageCode': 'en',
        'countryCode': 'US',
        'content': 'Some content',
        'sourceName': 'Source',
        'sourceUrl': 'https://example.com',
        'rightsStatus': 'public_domain',
        'isApproved': false,
      });

      await fakeFirestore.collection('daily_poems').doc('en_20260729').set({
        'date': '2026-07-29',
        'languageCode': 'en',
        'poemId': 'unapproved',
        'isPublished': true,
      });

      expect(
        () => repository.getDailyPoem(
          date: DateTime(2026, 7, 29),
          languageCode: 'en',
        ),
        throwsA(isA<InvalidPoemDataFailure>()),
      );
    });

    test(
      'throws DailyPoemNotFoundFailure for unpublished assignment',
      () async {
        await fakeFirestore.collection('daily_poems').doc('en_20260730').set({
          'date': '2026-07-30',
          'languageCode': 'en',
          'poemId': 'poem1',
          'isPublished': false,
        });

        expect(
          () => repository.getDailyPoem(
            date: DateTime(2026, 7, 30),
            languageCode: 'en',
          ),
          throwsA(isA<DailyPoemNotFoundFailure>()),
        );
      },
    );
  });

  group('getPoemsByIds', () {
    test('returns poems for valid IDs', () async {
      await fakeFirestore.collection('poems').doc('p2').set({
        'title': 'Rota',
        'author': 'Maria Konopnicka',
        'languageCode': 'pl',
        'countryCode': 'PL',
        'content': 'Content',
        'sourceName': 'Poezje',
        'sourceUrl': 'https://pl.wikisource.org',
        'rightsStatus': 'public_domain',
        'isApproved': true,
      });

      final poems = await repository.getPoemsByIds(['poem1', 'p2']);

      expect(poems, hasLength(2));
    });

    test('returns empty list for empty input', () async {
      final poems = await repository.getPoemsByIds([]);
      expect(poems, isEmpty);
    });
  });
}
