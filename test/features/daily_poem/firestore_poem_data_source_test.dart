import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daily_stanza/features/daily_poem/data/datasource/firestore_poem_data_source.dart';
import 'package:daily_stanza/features/daily_poem/data/exception/poem_data_exception.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirestorePoemDataSource dataSource;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    dataSource = FirestorePoemDataSource(firestore: fakeFirestore);
  });

  group('loadDailyPoem', () {
    setUp(() async {
      // Seed a valid poem.
      await fakeFirestore.collection('poems').doc('poem1').set({
        'title': 'The Road Not Taken',
        'author': 'Robert Frost',
        'languageCode': 'en',
        'countryCode': 'US',
        'content': 'Two roads diverged...',
        'sourceName': 'Mountain Interval',
        'sourceUrl': 'https://gutenberg.org',
        'rightsStatus': 'public_domain',
        'isApproved': true,
      });

      // Seed a valid published daily assignment.
      await fakeFirestore.collection('daily_poems').doc('en_20260728').set({
        'date': '2026-07-28',
        'languageCode': 'en',
        'poemId': 'poem1',
        'isPublished': true,
      });
    });

    test('returns valid assignment and poem', () async {
      final (poem, isFromCache) = await dataSource.loadDailyPoem(
        date: DateTime(2026, 7, 28),
        languageCode: 'en',
      );

      expect(poem.id, 'poem1');
      expect(poem.title, 'The Road Not Taken');
      expect(poem.author, 'Robert Frost');
      expect(poem.isApproved, true);
      expect(isFromCache, isA<bool>());
    });

    test('throws DailyPoemNotFoundException for missing assignment', () {
      expect(
        () => dataSource.loadDailyPoem(
          date: DateTime(2099, 1, 1),
          languageCode: 'en',
        ),
        throwsA(isA<DailyPoemNotFoundException>()),
      );
    });

    test('throws PoemNotFoundException for missing referenced poem', () async {
      // Create assignment referencing non-existent poem.
      await fakeFirestore.collection('daily_poems').doc('en_20260729').set({
        'date': '2026-07-29',
        'languageCode': 'en',
        'poemId': 'nonexistent_poem',
        'isPublished': true,
      });

      expect(
        () => dataSource.loadDailyPoem(
          date: DateTime(2026, 7, 29),
          languageCode: 'en',
        ),
        throwsA(isA<PoemNotFoundException>()),
      );
    });

    test(
      'throws AssignmentNotPublishedException for unpublished assignment',
      () async {
        await fakeFirestore.collection('daily_poems').doc('en_20260730').set({
          'date': '2026-07-30',
          'languageCode': 'en',
          'poemId': 'poem1',
          'isPublished': false,
        });

        expect(
          () => dataSource.loadDailyPoem(
            date: DateTime(2026, 7, 30),
            languageCode: 'en',
          ),
          throwsA(isA<AssignmentNotPublishedException>()),
        );
      },
    );

    test('throws PoemNotApprovedException for unapproved poem', () async {
      // Create unapproved poem.
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

      await fakeFirestore.collection('daily_poems').doc('en_20260731').set({
        'date': '2026-07-31',
        'languageCode': 'en',
        'poemId': 'unapproved',
        'isPublished': true,
      });

      expect(
        () => dataSource.loadDailyPoem(
          date: DateTime(2026, 7, 31),
          languageCode: 'en',
        ),
        throwsA(isA<PoemNotApprovedException>()),
      );
    });

    test('throws FormatException for malformed poem data', () async {
      // Create poem missing required fields.
      await fakeFirestore.collection('poems').doc('malformed').set({
        'title': '',
        'author': '',
        'languageCode': '',
        'countryCode': 'US',
        'content': '',
        'sourceName': '',
        'sourceUrl': '',
        'rightsStatus': 'public_domain',
        'isApproved': true,
      });

      await fakeFirestore.collection('daily_poems').doc('en_20260801').set({
        'date': '2026-08-01',
        'languageCode': 'en',
        'poemId': 'malformed',
        'isPublished': true,
      });

      expect(
        () => dataSource.loadDailyPoem(
          date: DateTime(2026, 8, 1),
          languageCode: 'en',
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('loadPoemsByIds', () {
    setUp(() async {
      await fakeFirestore.collection('poems').doc('p1').set({
        'title': 'Poem 1',
        'author': 'Author 1',
        'languageCode': 'en',
        'countryCode': 'US',
        'content': 'Content 1',
        'sourceName': 'Source 1',
        'sourceUrl': 'https://example.com/1',
        'rightsStatus': 'public_domain',
        'isApproved': true,
      });

      await fakeFirestore.collection('poems').doc('p2').set({
        'title': 'Poem 2',
        'author': 'Author 2',
        'languageCode': 'pl',
        'countryCode': 'PL',
        'content': 'Content 2',
        'sourceName': 'Source 2',
        'sourceUrl': 'https://example.com/2',
        'rightsStatus': 'public_domain',
        'isApproved': true,
      });
    });

    test('loads multiple poems by IDs', () async {
      final poems = await dataSource.loadPoemsByIds(['p1', 'p2']);

      expect(poems, hasLength(2));
      expect(poems.map((p) => p.id).toSet(), containsAll(['p1', 'p2']));
    });

    test('returns empty list for empty input', () async {
      final poems = await dataSource.loadPoemsByIds([]);
      expect(poems, isEmpty);
    });

    test('returns only found poems for mixed IDs', () async {
      final poems = await dataSource.loadPoemsByIds(['p1', 'nonexistent']);

      expect(poems, hasLength(1));
      expect(poems.first.id, 'p1');
    });
  });
}
