import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:daily_stanza/features/daily_poem/data/dto/poem_dto.dart';

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

  group('PoemDto', () {
    test('maps from Firestore document correctly', () {
      final doc = MockDocumentSnapshot(
        id: 'test_poem',
        data: const {
          'title': 'Test Poem',
          'author': 'Test Author',
          'languageCode': 'en',
          'countryCode': 'US',
          'content': 'Line one\nLine two',
          'sourceName': 'Test Source',
          'sourceUrl': 'https://example.com',
          'rightsStatus': 'public_domain',
          'isApproved': true,
        },
      );

      final dto = PoemDto.fromFirestore(doc);

      expect(dto.id, 'test_poem');
      expect(dto.title, 'Test Poem');
      expect(dto.author, 'Test Author');
      expect(dto.languageCode, 'en');
      expect(dto.countryCode, 'US');
      expect(dto.content, 'Line one\nLine two');
      expect(dto.sourceName, 'Test Source');
      expect(dto.sourceUrl, 'https://example.com');
      expect(dto.rightsStatus, 'public_domain');
      expect(dto.isApproved, true);
    });

    test('converts to domain model', () {
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

      final poem = dto.toDomain();

      expect(poem.id, 'id1');
      expect(poem.title, 'Title');
      expect(poem.author, 'Author');
      expect(poem.languageCode, 'en');
    });

    test('validate passes for valid DTO', () {
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

      expect(() => dto.validate(), returnsNormally);
    });

    test('validate throws for empty title', () {
      const dto = PoemDto(
        id: 'id1',
        title: '',
        author: 'Author',
        languageCode: 'en',
        countryCode: 'US',
        content: 'Content',
        sourceName: 'Source',
        sourceUrl: 'https://example.com',
        rightsStatus: 'public_domain',
        isApproved: true,
      );

      expect(() => dto.validate(), throwsA(isA<FormatException>()));
    });

    test('validate throws for empty author', () {
      const dto = PoemDto(
        id: 'id1',
        title: 'Title',
        author: '',
        languageCode: 'en',
        countryCode: 'US',
        content: 'Content',
        sourceName: 'Source',
        sourceUrl: 'https://example.com',
        rightsStatus: 'public_domain',
        isApproved: true,
      );

      expect(() => dto.validate(), throwsA(isA<FormatException>()));
    });

    test('validate throws for empty content', () {
      const dto = PoemDto(
        id: 'id1',
        title: 'Title',
        author: 'Author',
        languageCode: 'en',
        countryCode: 'US',
        content: '',
        sourceName: 'Source',
        sourceUrl: 'https://example.com',
        rightsStatus: 'public_domain',
        isApproved: true,
      );

      expect(() => dto.validate(), throwsA(isA<FormatException>()));
    });

    test('validate throws for empty languageCode', () {
      const dto = PoemDto(
        id: 'id1',
        title: 'Title',
        author: 'Author',
        languageCode: '',
        countryCode: 'US',
        content: 'Content',
        sourceName: 'Source',
        sourceUrl: 'https://example.com',
        rightsStatus: 'public_domain',
        isApproved: true,
      );

      expect(() => dto.validate(), throwsA(isA<FormatException>()));
    });

    test('throws FormatException for null document data', () {
      final doc = MockDocumentSnapshot(id: 'empty', data: null);

      expect(() => PoemDto.fromFirestore(doc), throwsA(isA<FormatException>()));
    });
  });
}
