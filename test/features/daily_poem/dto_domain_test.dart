import 'package:flutter_test/flutter_test.dart';
import 'package:daily_stanza/features/daily_poem/data/dto/daily_poem_assignment_dto.dart';
import 'package:daily_stanza/features/daily_poem/data/dto/poem_dto.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/daily_poem_assignment.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/poem.dart';

void main() {
  group('PoemDto.toDomain', () {
    test('converts all fields to Poem domain model', () {
      const dto = PoemDto(
        id: 'frost_road',
        title: 'The Road Not Taken',
        author: 'Robert Frost',
        languageCode: 'en',
        countryCode: 'US',
        content: 'Two roads diverged in a yellow wood',
        sourceName: 'Mountain Interval',
        sourceUrl: 'https://gutenberg.org',
        rightsStatus: 'public_domain',
        isApproved: true,
      );

      final poem = dto.toDomain();

      expect(poem, isA<Poem>());
      expect(poem.id, 'frost_road');
      expect(poem.title, 'The Road Not Taken');
      expect(poem.author, 'Robert Frost');
      expect(poem.languageCode, 'en');
      expect(poem.countryCode, 'US');
      expect(poem.content, 'Two roads diverged in a yellow wood');
      expect(poem.sourceName, 'Mountain Interval');
      expect(poem.sourceUrl, 'https://gutenberg.org');
      expect(poem.rightsStatus, 'public_domain');
    });

    test('domain model does not expose isApproved', () {
      const dto = PoemDto(
        id: 'id1',
        title: 'Title',
        author: 'Author',
        languageCode: 'pl',
        countryCode: 'PL',
        content: 'Content',
        sourceName: 'Source',
        sourceUrl: 'https://example.com',
        rightsStatus: 'public_domain',
        isApproved: false,
      );

      final poem = dto.toDomain();

      // Poem domain model has no isApproved field — data-layer concern stays
      // in data layer.
      expect(poem.props, isNot(contains(false)));
    });

    test('preserves Equatable equality', () {
      const dto = PoemDto(
        id: 'id1',
        title: 'Title',
        author: 'Author',
        languageCode: 'en',
        countryCode: 'US',
        content: 'Content',
        sourceName: 'Source',
        sourceUrl: 'https://example.com',
        rightsStatus: 'public_domain',
        isApproved: true,
      );

      final poem1 = dto.toDomain();
      final poem2 = dto.toDomain();

      expect(poem1, equals(poem2));
    });
  });

  group('DailyPoemAssignmentDto.toDomain', () {
    test('converts all fields to DailyPoemAssignment', () {
      final dto = DailyPoemAssignmentDto(
        date: DateTime(2026, 7, 28),
        languageCode: 'en',
        poemId: 'frost_road',
        isPublished: true,
      );

      final assignment = dto.toDomain();

      expect(assignment, isA<DailyPoemAssignment>());
      expect(assignment.date, DateTime(2026, 7, 28));
      expect(assignment.languageCode, 'en');
      expect(assignment.poemId, 'frost_road');
      expect(assignment.isPublished, true);
    });

    test('unpublished assignment converts correctly', () {
      final dto = DailyPoemAssignmentDto(
        date: DateTime(2026, 8, 1),
        languageCode: 'pl',
        poemId: 'konopnicka_rota',
        isPublished: false,
      );

      final assignment = dto.toDomain();

      expect(assignment.isPublished, false);
      expect(assignment.languageCode, 'pl');
    });

    test('preserves Equatable equality', () {
      final dto = DailyPoemAssignmentDto(
        date: DateTime(2026, 7, 28),
        languageCode: 'en',
        poemId: 'poem1',
        isPublished: true,
      );

      final a1 = dto.toDomain();
      final a2 = dto.toDomain();

      expect(a1, equals(a2));
    });
  });
}
