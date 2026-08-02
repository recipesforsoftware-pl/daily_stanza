import 'dart:io';

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

List<Map<String, dynamic>> _fullPoemSet() {
  return [
    _validPoem(id: 'en_poem_a', languageCode: 'en', countryCode: 'GB'),
    _validPoem(id: 'en_poem_b', languageCode: 'en', countryCode: 'GB'),
    _validPoem(id: 'en_poem_c', languageCode: 'en', countryCode: 'GB'),
    _validPoem(id: 'en_poem_d', languageCode: 'en', countryCode: 'GB'),
    _validPoem(id: 'en_poem_e', languageCode: 'en', countryCode: 'GB'),
    _validPoem(id: 'en_poem_f', languageCode: 'en', countryCode: 'GB'),
    _validPoem(id: 'en_poem_g', languageCode: 'en', countryCode: 'GB'),
    _validPoem(id: 'en_poem_h', languageCode: 'en', countryCode: 'GB'),
    _validPoem(id: 'pl_poem_a', languageCode: 'pl', countryCode: 'PL'),
    _validPoem(id: 'pl_poem_b', languageCode: 'pl', countryCode: 'PL'),
    _validPoem(id: 'pl_poem_c', languageCode: 'pl', countryCode: 'PL'),
    _validPoem(id: 'pl_poem_d', languageCode: 'pl', countryCode: 'PL'),
    _validPoem(id: 'pl_poem_e', languageCode: 'pl', countryCode: 'PL'),
    _validPoem(id: 'pl_poem_f', languageCode: 'pl', countryCode: 'PL'),
    _validPoem(id: 'pl_poem_g', languageCode: 'pl', countryCode: 'PL'),
    _validPoem(id: 'pl_poem_h', languageCode: 'pl', countryCode: 'PL'),
  ];
}

List<Map<String, dynamic>> _fullAssignmentSet(
  List<Map<String, dynamic>> poems,
) {
  final enPoems = poems
      .where((p) => p['languageCode'] == 'en')
      .map((p) => p['id'] as String)
      .toList();
  final plPoems = poems
      .where((p) => p['languageCode'] == 'pl')
      .map((p) => p['id'] as String)
      .toList();
  final assignments = <Map<String, dynamic>>[];
  for (var i = 0; i < 365; i++) {
    final d = DateTime(2026, 7, 30 + i);
    final ds =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final dc =
        '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';
    assignments.add(
      _validAssignment(
        id: 'en_$dc',
        date: ds,
        languageCode: 'en',
        poemId: enPoems[i % enPoems.length],
      ),
    );
    assignments.add(
      _validAssignment(
        id: 'pl_$dc',
        date: ds,
        languageCode: 'pl',
        poemId: plPoems[i % plPoems.length],
      ),
    );
  }
  return assignments;
}

void main() {
  group('CatalogValidator – poem validation', () {
    test('1. valid full catalog passes', () {
      final poems = _fullPoemSet();
      final assignments = _fullAssignmentSet(poems);
      final result = CatalogValidator.validateData(
        poems: poems,
        assignments: assignments,
      );
      expect(result.isValid, isTrue);
    });

    test('1b. full catalog from seed files passes', () {
      final poemsFile = File('firebase/seed/poems.json');
      final dailyFile = File('firebase/seed/daily_poems.json');
      if (!poemsFile.existsSync() || !dailyFile.existsSync()) return;
      final result = CatalogValidator.validate(
        poemsPath: poemsFile.path,
        assignmentsPath: dailyFile.path,
      );
      expect(result.isValid, isTrue);
      expect(result.summary.totalPoems, 16);
      expect(result.summary.englishPoems, 8);
      expect(result.summary.polishPoems, 8);
      expect(result.summary.totalAssignments, 730);
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
      final recordErrors = result.errors.where(
        (e) => !e.record.startsWith('catalog'),
      );
      expect(recordErrors, isEmpty);
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
      final recordErrors = result.errors.where(
        (e) => !e.record.startsWith('catalog'),
      );
      expect(recordErrors, isEmpty);
    });

    test('20. short poem (miniature) passes', () {
      final poems = [_validPoem(content: 'Roses are red,\nViolets are blue.')];
      final result = CatalogValidator.validateData(
        poems: poems,
        assignments: [],
      );
      final recordErrors = result.errors.where(
        (e) => !e.record.startsWith('catalog'),
      );
      expect(recordErrors, isEmpty);
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
      final recordErrors = result.errors.where(
        (e) => !e.record.startsWith('catalog'),
      );
      expect(recordErrors, isEmpty);
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

  group('CatalogValidator – invariants', () {
    test('23. wrong poem count fails', () {
      final poems = [_validPoem()];
      final result = CatalogValidator.validateData(
        poems: poems,
        assignments: [],
      );
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.message.contains('16')), isTrue);
    });

    test('24. wrong English/Polish count fails', () {
      final poems = [
        _validPoem(id: 'e1'),
        _validPoem(id: 'e2'),
        _validPoem(id: 'e3'),
        _validPoem(id: 'e4'),
        _validPoem(id: 'e5'),
        _validPoem(id: 'e6'),
        _validPoem(id: 'e7'),
        _validPoem(id: 'e8'),
        _validPoem(id: 'e9'),
        _validPoem(id: 'e10'),
        _validPoem(id: 'p1', languageCode: 'pl', countryCode: 'PL'),
        _validPoem(id: 'p2', languageCode: 'pl', countryCode: 'PL'),
        _validPoem(id: 'p3', languageCode: 'pl', countryCode: 'PL'),
        _validPoem(id: 'p4', languageCode: 'pl', countryCode: 'PL'),
        _validPoem(id: 'p5', languageCode: 'pl', countryCode: 'PL'),
      ];
      final result = CatalogValidator.validateData(
        poems: poems,
        assignments: _fullAssignmentSet(poems),
      );
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.message.contains('English')), isTrue);
    });

    test('25. wrong assignment count fails', () {
      final poems = _fullPoemSet();
      final result = CatalogValidator.validateData(
        poems: poems,
        assignments: [],
      );
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.message.contains('730')), isTrue);
    });

    test('26. wrong per-language assignment count fails', () {
      final poems = _fullPoemSet();
      final result = CatalogValidator.validateData(
        poems: poems,
        assignments: [_validAssignment(poemId: 'en_poem_a')],
      );
      expect(result.isValid, isFalse);
    });

    test('27. date range validation fails', () {
      final poems = _fullPoemSet();
      final assignments = [
        _validAssignment(
          id: 'en_20260101',
          date: '2026-01-01',
          poemId: 'en_poem_a',
        ),
      ];
      final result = CatalogValidator.validateData(
        poems: poems,
        assignments: assignments,
      );
      expect(result.isValid, isFalse);
      expect(
        result.errors.any((e) => e.field == 'assignments.date_range'),
        isTrue,
      );
    });

    test('28. poem never used fails', () {
      final poems = _fullPoemSet();
      final result = CatalogValidator.validateData(
        poems: poems,
        assignments: [
          _validAssignment(
            id: 'en_20260730',
            date: '2026-07-30',
            poemId: 'en_poem_a',
          ),
        ],
      );
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.field == 'poem.never_used'), isTrue);
    });
  });
}
