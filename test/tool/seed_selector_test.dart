import 'package:flutter_test/flutter_test.dart';

import '../../tool/seed_selector.dart';

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
  String id = 'en_20260803',
  String date = '2026-08-03',
  String languageCode = 'en',
  String poemId = 'en_poem_a',
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

Matcher _throwsSelection(String messagePart) => throwsA(
  isA<SeedSelectionException>().having(
    (error) => error.message,
    'message',
    contains(messagePart),
  ),
);

void main() {
  group('selectDailyAssignments', () {
    test(
      'valid date selects exactly one English and one Polish assignment',
      () {
        final assignments = [
          _validAssignment(id: 'en_20260803', languageCode: 'en'),
          _validAssignment(id: 'pl_20260803', languageCode: 'pl'),
          _validAssignment(
            id: 'en_20260804',
            date: '2026-08-04',
            languageCode: 'en',
          ),
          _validAssignment(
            id: 'pl_20260804',
            date: '2026-08-04',
            languageCode: 'pl',
          ),
        ];

        final selected = selectDailyAssignments(
          assignments,
          isoDate: '2026-08-03',
        );

        expect(selected, hasLength(2));
        expect(selected.map((a) => a['id']).toSet(), {
          'en_20260803',
          'pl_20260803',
        });
        expect(selected.map((a) => a['languageCode']).toSet(), {'en', 'pl'});
      },
    );

    test('selected assignments retain their original ids and dates', () {
      final en = _validAssignment(id: 'en_20260803', languageCode: 'en');
      final pl = _validAssignment(id: 'pl_20260803', languageCode: 'pl');

      final selected = selectDailyAssignments([en, pl], isoDate: '2026-08-03');

      expect(selected, hasLength(2));
      expect(selected[0]['id'], 'en_20260803');
      expect(selected[0]['date'], '2026-08-03');
      expect(selected[1]['id'], 'pl_20260803');
      expect(selected[1]['date'], '2026-08-03');
      expect(selected[0], same(en));
      expect(selected[1], same(pl));
    });

    test('missing date fails', () {
      final assignments = [
        _validAssignment(id: 'en_20260803', languageCode: 'en'),
        _validAssignment(id: 'pl_20260803', languageCode: 'pl'),
      ];

      expect(
        () => selectDailyAssignments(assignments, isoDate: '2026-12-25'),
        _throwsSelection('2026-12-25'),
      );
    });

    test('only one language for a date fails', () {
      final assignments = [
        _validAssignment(id: 'en_20260803', languageCode: 'en'),
      ];

      expect(
        () => selectDailyAssignments(assignments, isoDate: '2026-08-03'),
        _throwsSelection('no pl assignment found'),
      );
    });

    test('duplicate language for a date fails', () {
      final assignments = [
        _validAssignment(id: 'en_20260803', languageCode: 'en'),
        _validAssignment(id: 'en_20260803', languageCode: 'en'),
        _validAssignment(id: 'pl_20260803', languageCode: 'pl'),
      ];

      expect(
        () => selectDailyAssignments(assignments, isoDate: '2026-08-03'),
        _throwsSelection('duplicate'),
      );
    });

    test('mismatched id and date fails', () {
      final assignments = [
        _validAssignment(id: 'en_20260804', date: '2026-08-03'),
        _validAssignment(id: 'pl_20260803', languageCode: 'pl'),
      ];

      expect(
        () => selectDailyAssignments(assignments, isoDate: '2026-08-03'),
        _throwsSelection('en_20260803'),
      );
    });

    test('malformed language code fails', () {
      final assignments = [
        _validAssignment(id: 'en_20260803', languageCode: 'en'),
        _validAssignment(id: 'pl_20260803', languageCode: 'fr'),
      ];

      expect(
        () => selectDailyAssignments(assignments, isoDate: '2026-08-03'),
        _throwsSelection('malformed languageCode'),
      );
    });
  });

  group('buildSeedPlan', () {
    test('valid catalog yields all 16 poems and exactly two assignments', () {
      final poems = _fullPoemSet();
      final assignments = _fullAssignmentSet(poems);

      final plan = buildSeedPlan(
        poems: poems,
        assignments: assignments,
        isoDate: '2026-08-03',
      );

      expect(plan.poems, hasLength(16));
      expect(plan.assignments, hasLength(2));
      expect(plan.assignments.map((a) => a['id']).toSet(), {
        'en_20260803',
        'pl_20260803',
      });
    });

    test('complete catalog validation runs before selection', () {
      final poems = _fullPoemSet();
      final assignments = _fullAssignmentSet(poems);
      final brokenPoems = [
        for (var i = 0; i < poems.length; i++)
          if (i == 0)
            Map<String, dynamic>.from(poems[i])..['isApproved'] = false
          else
            poems[i],
      ];

      expect(
        () => buildSeedPlan(
          poems: brokenPoems,
          assignments: assignments,
          isoDate: '2026-08-03',
        ),
        _throwsSelection('Catalog validation failed'),
      );
    });

    test('complete catalog validation gates the write plan', () {
      final poems = _fullPoemSet();
      final assignments = _fullAssignmentSet(poems);

      final plan = buildSeedPlan(
        poems: poems,
        assignments: assignments,
        isoDate: '2026-08-03',
      );

      expect(plan.poems.length + plan.assignments.length, 18);
    });

    test('valid catalog but missing date blocks the plan', () {
      final poems = _fullPoemSet();
      final assignments = _fullAssignmentSet(poems);

      expect(
        () => buildSeedPlan(
          poems: poems,
          assignments: assignments,
          isoDate: '2028-01-01',
        ),
        _throwsSelection('2028-01-01'),
      );
    });
  });
}
