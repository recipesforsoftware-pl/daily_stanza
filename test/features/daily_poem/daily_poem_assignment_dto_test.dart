import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:daily_stanza/features/daily_poem/data/dto/daily_poem_assignment_dto.dart';

// ignore_for_file: subtype_of_sealed_class
class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {
  MockDocumentSnapshot({required String id, Map<String, dynamic>? data})
    : _id = id,
      _data = data;

  final String _id;
  final Map<String, dynamic>? _data;

  @override
  String get id => _id;

  @override
  Map<String, dynamic>? data() => _data;

  @override
  bool get exists => _data != null;

  @override
  SnapshotMetadata get metadata => const FakeSnapshotMetadata();
}

class FakeSnapshotMetadata implements SnapshotMetadata {
  const FakeSnapshotMetadata();

  @override
  bool get hasPendingWrites => false;

  @override
  bool get isFromCache => false;
}

void main() {
  setUpAll(() {
    registerFallbackValue(const FakeSnapshotMetadata());
  });

  group('DailyPoemAssignmentDto', () {
    test('maps from Firestore Timestamp document', () {
      final doc = MockDocumentSnapshot(
        id: 'en_20260728',
        data: {
          'date': Timestamp.fromDate(DateTime(2026, 7, 28)),
          'languageCode': 'en',
          'poemId': 'frost_road_not_taken',
          'isPublished': true,
        },
      );

      final dto = DailyPoemAssignmentDto.fromFirestore(doc);

      expect(dto.languageCode, 'en');
      expect(dto.poemId, 'frost_road_not_taken');
      expect(dto.isPublished, true);
      expect(dto.date, DateTime(2026, 7, 28));
    });

    test('maps from string date document', () {
      final doc = MockDocumentSnapshot(
        id: 'pl_20260728',
        data: const {
          'date': '2026-07-28',
          'languageCode': 'pl',
          'poemId': 'konopnicka_rota',
          'isPublished': true,
        },
      );

      final dto = DailyPoemAssignmentDto.fromFirestore(doc);

      expect(dto.languageCode, 'pl');
      expect(dto.poemId, 'konopnicka_rota');
      expect(dto.date, DateTime(2026, 7, 28));
    });

    test('converts to domain model', () {
      final doc = MockDocumentSnapshot(
        id: 'en_20260728',
        data: {
          'date': Timestamp.fromDate(DateTime(2026, 7, 28)),
          'languageCode': 'en',
          'poemId': 'poem1',
          'isPublished': true,
        },
      );

      final dto = DailyPoemAssignmentDto.fromFirestore(doc);
      final assignment = dto.toDomain();

      expect(assignment.languageCode, 'en');
      expect(assignment.poemId, 'poem1');
      expect(assignment.isPublished, true);
      expect(assignment.date, DateTime(2026, 7, 28));
    });

    test('throws FormatException for null data', () {
      final doc = MockDocumentSnapshot(id: 'bad', data: null);

      expect(
        () => DailyPoemAssignmentDto.fromFirestore(doc),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException for invalid date format', () {
      final doc = MockDocumentSnapshot(
        id: 'bad_date',
        data: {
          'date': 12345, // neither Timestamp nor String
          'languageCode': 'en',
          'poemId': 'poem1',
          'isPublished': true,
        },
      );

      expect(
        () => DailyPoemAssignmentDto.fromFirestore(doc),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
