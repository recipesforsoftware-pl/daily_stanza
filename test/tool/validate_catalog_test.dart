import 'package:flutter_test/flutter_test.dart';

import '../../tool/catalog_validator.dart';

Map<String, dynamic> _validPoem({
  String id = 'test_poem',
  String title = 'Test Poem',
  String author = 'Test Author',
  String languageCode = 'en',
  String countryCode = 'GB',
  String content =
      'Line one\nLine two\nLine three\nLine four\nLine five\n'
      'Line six\nLine seven\nLine eight\nLine nine\nLine ten',
  String sourceName = 'Test Source',
  String sourceUrl = 'https://example.com/poem',
  String rightsStatus = 'public_domain',
  bool isApproved = true,
}) => {
  'id': id,
  'title': title,
  'author': author,
  'languageCode': languageCode,
  'countryCode': countryCode,
  'content': content,
  'sourceName': sourceName,
  'sourceUrl': sourceUrl,
  'rightsStatus': rightsStatus,
  'isApproved': isApproved,
};

Map<String, dynamic> _validAssignment({
  String id = 'en_20260728',
  String date = '2026-07-28',
  String languageCode = 'en',
  String poemId = 'test_poem',
  bool isPublished = true,
}) => {
  'id': id,
  'date': date,
  'languageCode': languageCode,
  'poemId': poemId,
  'isPublished': isPublished,
};

void main() {
  group('CatalogValidator – poem validation', () {
    test('1. current valid sample passes', () {
      final poems = [
        _validPoem(
          id: 'william_blake_the_tyger',
          title: 'The Tyger',
          author: 'William Blake',
          languageCode: 'en',
          countryCode: 'GB',
          content:
              'Tyger Tyger, burning bright,\n'
              'In the forests of the night;\n'
              'What immortal hand or eye,\n'
              'Could frame thy fearful symmetry?\n'
              'In what distant deeps or skies,\n'
              'Burnt the fire of thine eyes?',
          sourceName: 'Songs of Experience (1794)',
          sourceUrl: 'https://en.wikisource.org/wiki/The_Tyger',
        ),
        _validPoem(
          id: 'juliusz_slowacki_testament_moj',
          title: 'Testament mój',
          author: 'Juliusz Słowacki',
          languageCode: 'pl',
          countryCode: 'PL',
          content:
              'Żyłem z wami, cierpiałem i płakałem z wami,\n'
              'Nigdy mi, kto szlachetny, nie był obojętny,\n'
              'Dziś was rzucam i dalej idę w cień — z duchami —\n'
              'A jak gdyby tu szczęście było — idę smętny.',
          sourceName: 'Dzieła Juliusza Słowackiego (1888)',
          sourceUrl: 'https://pl.wikisource.org/wiki/Testament_m%C3%B3j',
        ),
      ];
      final assignments = [
        _validAssignment(
          id: 'en_20260728',
          date: '2026-07-28',
          languageCode: 'en',
          poemId: 'william_blake_the_tyger',
        ),
        _validAssignment(
          id: 'pl_20260728',
          date: '2026-07-28',
          languageCode: 'pl',
          poemId: 'juliusz_slowacki_testament_moj',
        ),
      ];

      final result = CatalogValidator.validateData(
        poems: poems,
        assignments: assignments,
      );

      expect(result.isValid, isTrue);
    });

    test('2. duplicate poem ID fails', () {
      final poems = [_validPoem(id: 'dup_id'), _validPoem(id: 'dup_id')];
      final result = CatalogValidator.validateData(
        poems: poems,
        assignments: [_validAssignment(poemId: 'dup_id')],
      );
      expect(result.isValid, isFalse);
      expect(
        result.errors.any(
          (e) => e.field == 'id' && e.message.contains('duplicate'),
        ),
        isTrue,
      );
    });

    test('3. missing title fails', () {
      final poems = [_validPoem(title: '')];
      final result = CatalogValidator.validateData(
        poems: poems,
        assignments: [],
      );
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.field == 'title'), isTrue);
    });

    test('4. unsupported language fails', () {
      final poems = [_validPoem(languageCode: 'fr')];
      final result = CatalogValidator.validateData(
        poems: poems,
        assignments: [],
      );
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.field == 'languageCode'), isTrue);
    });

    test('5. invalid country code fails', () {
      final poems = [_validPoem(countryCode: 'GBR')];
      final result = CatalogValidator.validateData(
        poems: poems,
        assignments: [],
      );
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.field == 'countryCode'), isTrue);
    });

    test('6. empty content fails', () {
      final poems = [_validPoem(content: '')];
      final result = CatalogValidator.validateData(
        poems: poems,
        assignments: [],
      );
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.field == 'content'), isTrue);
    });

    test('7. placeholder content fails', () {
      final poems = [
        _validPoem(
          content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
        ),
      ];
      final result = CatalogValidator.validateData(
        poems: poems,
        assignments: [],
      );
      expect(result.isValid, isFalse);
      expect(
        result.errors.any(
          (e) => e.field == 'content' && e.message.contains('placeholder'),
        ),
        isTrue,
      );
    });

    test('8. missing sourceName fails', () {
      final poems = [_validPoem(sourceName: '')];
      final result = CatalogValidator.validateData(
        poems: poems,
        assignments: [],
      );
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.field == 'sourceName'), isTrue);
    });

    test('9. invalid sourceUrl fails', () {
      final poems = [_validPoem(sourceUrl: 'http://example.com')];
      final result = CatalogValidator.validateData(
        poems: poems,
        assignments: [],
      );
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.field == 'sourceUrl'), isTrue);
    });

    test('10. non-public-domain rightsStatus fails', () {
      final poems = [_validPoem(rightsStatus: 'copyright')];
      final result = CatalogValidator.validateData(
        poems: poems,
        assignments: [],
      );
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.field == 'rightsStatus'), isTrue);
    });

    test('11. unapproved poem fails', () {
      final poems = [_validPoem(isApproved: false)];
      final result = CatalogValidator.validateData(
        poems: poems,
        assignments: [],
      );
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.field == 'isApproved'), isTrue);
    });
  });

  group('CatalogValidator – assignment validation', () {
    test('12. duplicate assignment ID fails', () {
      final poems = [_validPoem()];
      final assignments = [
        _validAssignment(poemId: 'test_poem'),
        _validAssignment(id: 'en_20260728', poemId: 'test_poem'),
      ];
      final result = CatalogValidator.validateData(
        poems: poems,
        assignments: assignments,
      );
      expect(result.isValid, isFalse);
      expect(
        result.errors.any(
          (e) => e.field == 'id' && e.message.contains('duplicate'),
        ),
        isTrue,
      );
    });

    test('13. malformed assignment ID fails', () {
      final assignments = [_validAssignment(id: 'invalid_id')];
      final result = CatalogValidator.validateData(
        poems: [],
        assignments: assignments,
      );
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.field == 'id'), isTrue);
    });

    test('14. assignment date and ID mismatch fails', () {
      final assignments = [
        _validAssignment(id: 'en_20260728', date: '2026-07-29'),
      ];
      final result = CatalogValidator.validateData(
        poems: [],
        assignments: assignments,
      );
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.field == 'id/date'), isTrue);
    });

    test('15. missing referenced poem fails', () {
      final assignments = [
        _validAssignment(id: 'en_20260728', poemId: 'nonexistent_poem'),
      ];
      final result = CatalogValidator.validateData(
        poems: [],
        assignments: assignments,
      );
      expect(result.isValid, isFalse);
      expect(
        result.errors.any(
          (e) => e.field == 'poemId' && e.message.contains('unknown'),
        ),
        isTrue,
      );
    });

    test('16. assignment/poem language mismatch fails', () {
      final poems = [_validPoem(id: 'test_poem', languageCode: 'en')];
      final assignments = [
        _validAssignment(
          id: 'pl_20260728',
          languageCode: 'pl',
          poemId: 'test_poem',
        ),
      ];
      final result = CatalogValidator.validateData(
        poems: poems,
        assignments: assignments,
      );
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.field == 'languageCode'), isTrue);
    });

    test('17. unpublished assignment fails', () {
      final poems = [_validPoem()];
      final assignments = [
        _validAssignment(poemId: 'test_poem', isPublished: false),
      ];
      final result = CatalogValidator.validateData(
        poems: poems,
        assignments: assignments,
      );
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.field == 'isPublished'), isTrue);
    });
  });

  group('CatalogValidator – content quality', () {
    test('18. valid Polish Unicode content passes', () {
      final poems = [
        _validPoem(
          id: 'polish_test',
          languageCode: 'pl',
          countryCode: 'PL',
          content:
              'Żyłem z wami, cierpiałem i płakałem z wami,\n'
              'Nigdy mi, kto szlachetny, nie był obojętny,\n'
              'Dziś was rzucam i dalej idę w cień — z duchami —',
          sourceUrl: 'https://pl.wikisource.org/wiki/Test',
        ),
      ];
      final result = CatalogValidator.validateData(
        poems: poems,
        assignments: [],
      );
      expect(result.isValid, isTrue);
    });

    test('19. valid multiline poem content passes', () {
      final poems = [
        _validPoem(
          content:
              'Shall I compare thee to a summer\'s day?\n'
              'Thou art more lovely and more temperate:\n'
              'Rough winds do shake the darling buds of May,\n'
              'And summer\'s lease hath all too short a date;\n'
              'Sometime too hot the eye of heaven shines,\n'
              'And often is his gold complexion dimm\'d;',
        ),
      ];
      final result = CatalogValidator.validateData(
        poems: poems,
        assignments: [],
      );
      expect(result.isValid, isTrue);
    });

    test('20. short poem (miniature) passes', () {
      final poems = [_validPoem(content: 'Roses are red,\nViolets are blue.')];
      final result = CatalogValidator.validateData(
        poems: poems,
        assignments: [],
      );
      expect(result.isValid, isTrue);
    });

    test('21. ASCII-only Polish poem passes', () {
      final poems = [
        _validPoem(
          id: 'ascii_polish',
          languageCode: 'pl',
          countryCode: 'PL',
          content: 'Milo mi\nze tu jestes',
          sourceUrl: 'https://pl.wikisource.org/wiki/Test',
        ),
      ];
      final result = CatalogValidator.validateData(
        poems: poems,
        assignments: [],
      );
      expect(result.isValid, isTrue);
    });
  });

  group('CatalogValidator – summary', () {
    test('22. validation summary returns correct counts', () {
      final poems = [
        _validPoem(
          id: 'p1',
          title: 'E1',
          author: 'A',
          languageCode: 'en',
          countryCode: 'US',
        ),
        _validPoem(
          id: 'p2',
          title: 'E2',
          author: 'A',
          languageCode: 'en',
          countryCode: 'US',
        ),
        _validPoem(
          id: 'p3',
          title: 'P1',
          author: 'A',
          languageCode: 'pl',
          countryCode: 'PL',
        ),
      ];
      final assignments = [
        _validAssignment(id: 'en_20260728', date: '2026-07-28', poemId: 'p1'),
        _validAssignment(
          id: 'pl_20260729',
          date: '2026-07-29',
          languageCode: 'pl',
          poemId: 'p3',
        ),
      ];

      final result = CatalogValidator.validateData(
        poems: poems,
        assignments: assignments,
      );

      expect(result.summary.totalPoems, 3);
      expect(result.summary.englishPoems, 2);
      expect(result.summary.polishPoems, 1);
      expect(result.summary.totalAssignments, 2);
      expect(result.summary.earliestDate, '2026-07-28');
      expect(result.summary.latestDate, '2026-07-29');
    });
  });
}
