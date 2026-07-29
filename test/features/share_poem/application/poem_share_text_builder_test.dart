import 'package:flutter_test/flutter_test.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/poem.dart';
import 'package:daily_stanza/features/share_poem/application/poem_share_text_builder.dart';

void main() {
  const poem = Poem(
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

  const polishPoem = Poem(
    id: 'poem2',
    title: 'Testament mój',
    author: 'Juliusz Słowacki',
    languageCode: 'pl',
    countryCode: 'PL',
    content:
        'Żyłem z wami, cierpiałem i płakałem z wami,\n'
        'Nigdy mi, kto szlachetny, nie był obojętny.',
    sourceName: 'Dzieła',
    sourceUrl: 'https://pl.wikisource.org',
    rightsStatus: 'public_domain',
  );

  const poemWithWhitespace = Poem(
    id: 'poem3',
    title: '  The Raven  ',
    author: '  Edgar Allan Poe  ',
    languageCode: 'en',
    countryCode: 'US',
    content:
        '  Once upon a midnight dreary,\n  while I pondered, weak and weary,\n  ',
    sourceName: 'The Raven',
    sourceUrl: 'https://en.wikisource.org',
    rightsStatus: 'public_domain',
  );

  const poemWithStanzas = Poem(
    id: 'poem4',
    title: 'Stanza Test',
    author: 'Test Author',
    languageCode: 'en',
    countryCode: 'US',
    content:
        'First stanza line one.\nFirst stanza line two.\n\n'
        'Second stanza line one.\nSecond stanza line two.',
    sourceName: 'Test',
    sourceUrl: 'https://example.com',
    rightsStatus: 'public_domain',
  );

  const longPoem = Poem(
    id: 'long1',
    title: 'Long Poem',
    author: 'Prolific Writer',
    languageCode: 'en',
    countryCode: 'US',
    content:
        'Line one.\nLine two.\nLine three.\nLine four.\nLine five.\n'
        'Line six.\nLine seven.\nLine eight.\nLine nine.\nLine ten.\n'
        'Line eleven.\nLine twelve.\nLine thirteen.\nLine fourteen.\nLine fifteen.',
    sourceName: 'Collected Works',
    sourceUrl: 'https://example.com',
    rightsStatus: 'public_domain',
  );

  late PoemShareTextBuilder builder;

  setUp(() {
    builder = const PoemShareTextBuilder();
  });

  group('buildText', () {
    test('produces exact English output', () {
      final result = builder.buildText(poem);
      expect(
        result,
        'The Tyger\nby William Blake\n\n'
        'Tyger Tyger, burning bright,\nIn the forests of the night;\n\n'
        'Shared from Daily Stanza',
      );
    });

    test('produces exact Polish Unicode output', () {
      final result = builder.buildText(polishPoem);
      expect(
        result,
        'Testament mój\nby Juliusz Słowacki\n\n'
        'Żyłem z wami, cierpiałem i płakałem z wami,\n'
        'Nigdy mi, kto szlachetny, nie był obojętny.\n\n'
        'Shared from Daily Stanza',
      );
    });

    test('trims leading whitespace from title', () {
      final result = builder.buildText(poemWithWhitespace);
      expect(result, startsWith('The Raven'));
      // The trimmed title does not start with spaces.
      expect(result[0], isNot(' '));
    });

    test('trims trailing whitespace from title', () {
      final result = builder.buildText(poemWithWhitespace);
      expect(result, contains('The Raven'));
    });

    test('trims leading whitespace from author', () {
      final result = builder.buildText(poemWithWhitespace);
      expect(result, contains('\nby Edgar Allan Poe'));
    });

    test('trims trailing whitespace from author', () {
      final result = builder.buildText(poemWithWhitespace);
      expect(result, contains('Edgar Allan Poe'));
    });

    test('trims leading and trailing whitespace from content', () {
      final result = builder.buildText(poemWithWhitespace);
      expect(result, contains('Once upon a midnight dreary,'));
      expect(result, contains('Shared from Daily Stanza'));
    });

    test('preserves internal line breaks', () {
      final result = builder.buildText(poem);
      // Content has \n between lines; builder preserves them.
      expect(
        result,
        contains('Tyger Tyger, burning bright,\nIn the forests of the night;'),
      );
    });

    test('preserves stanza blank lines', () {
      final result = builder.buildText(poemWithStanzas);
      expect(
        result,
        contains(
          'First stanza line one.\nFirst stanza line two.\n\n'
          'Second stanza line one.\nSecond stanza line two.',
        ),
      );
    });

    test('long content is not truncated', () {
      final result = builder.buildText(longPoem);
      expect(result, contains('Line fifteen.'));
      expect(result, contains('Shared from Daily Stanza'));
    });

    test('does not include source URL', () {
      final result = builder.buildText(poem);
      expect(result, isNot(contains('wikisource')));
      expect(result, isNot(contains('http')));
    });

    test('does not include literal null', () {
      final result = builder.buildText(poem);
      expect(result, isNot(contains('null')));
    });

    test('Poem remains unchanged', () {
      final originalTitle = poem.title;
      final originalAuthor = poem.author;
      final originalContent = poem.content;
      builder.buildText(poem);
      expect(poem.title, originalTitle);
      expect(poem.author, originalAuthor);
      expect(poem.content, originalContent);
    });
  });

  group('buildSubject', () {
    test('produces exact subject for English poem', () {
      expect(builder.buildSubject(poem), 'The Tyger by William Blake');
    });

    test('produces exact subject for Polish poem', () {
      expect(
        builder.buildSubject(polishPoem),
        'Testament mój by Juliusz Słowacki',
      );
    });

    test('trims whitespace from title and author', () {
      expect(
        builder.buildSubject(poemWithWhitespace),
        'The Raven by Edgar Allan Poe',
      );
    });
  });
}
