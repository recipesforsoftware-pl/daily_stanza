import 'package:flutter_test/flutter_test.dart';
import 'package:daily_stanza/features/daily_poem/data/dto/daily_poem_assignment_dto.dart';

void main() {
  group('DailyPoemAssignmentDto.generateId', () {
    test('generates correct ID for English', () {
      final date = DateTime(2026, 7, 28);
      final id = DailyPoemAssignmentDto.generateId(
        date: date,
        languageCode: 'en',
      );
      expect(id, 'en_20260728');
    });

    test('generates correct ID for Polish', () {
      final date = DateTime(2026, 7, 28);
      final id = DailyPoemAssignmentDto.generateId(
        date: date,
        languageCode: 'pl',
      );
      expect(id, 'pl_20260728');
    });

    test('different dates produce different IDs', () {
      final date1 = DateTime(2026, 7, 28);
      final date2 = DateTime(2026, 7, 29);
      final id1 = DailyPoemAssignmentDto.generateId(
        date: date1,
        languageCode: 'en',
      );
      final id2 = DailyPoemAssignmentDto.generateId(
        date: date2,
        languageCode: 'en',
      );
      expect(id1, isNot(equals(id2)));
      expect(id1, 'en_20260728');
      expect(id2, 'en_20260729');
    });

    test('pads single-digit months and days', () {
      final date = DateTime(2026, 1, 5);
      final id = DailyPoemAssignmentDto.generateId(
        date: date,
        languageCode: 'en',
      );
      expect(id, 'en_20260105');
    });
  });
}
