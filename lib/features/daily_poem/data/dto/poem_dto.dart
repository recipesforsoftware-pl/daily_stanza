import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/poem.dart';

class PoemDto {
  const PoemDto({
    required this.id,
    required this.title,
    required this.author,
    required this.languageCode,
    required this.countryCode,
    required this.content,
    required this.sourceName,
    required this.sourceUrl,
    required this.rightsStatus,
    required this.isApproved,
  });

  factory PoemDto.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw FormatException('Poem document ${doc.id} has no data');
    }
    return PoemDto(
      id: doc.id,
      title: data['title'] as String? ?? '',
      author: data['author'] as String? ?? '',
      languageCode: data['languageCode'] as String? ?? '',
      countryCode: data['countryCode'] as String? ?? '',
      content: data['content'] as String? ?? '',
      sourceName: data['sourceName'] as String? ?? '',
      sourceUrl: data['sourceUrl'] as String? ?? '',
      rightsStatus: data['rightsStatus'] as String? ?? '',
      isApproved: data['isApproved'] as bool? ?? false,
    );
  }

  final String id;
  final String title;
  final String author;
  final String languageCode;
  final String countryCode;
  final String content;
  final String sourceName;
  final String sourceUrl;
  final String rightsStatus;
  final bool isApproved;

  Poem toDomain() {
    return Poem(
      id: id,
      title: title,
      author: author,
      languageCode: languageCode,
      countryCode: countryCode,
      content: content,
      sourceName: sourceName,
      sourceUrl: sourceUrl,
      rightsStatus: rightsStatus,
    );
  }

  void validate() {
    if (title.isEmpty) {
      throw const FormatException('Poem title is required');
    }
    if (author.isEmpty) {
      throw const FormatException('Poem author is required');
    }
    if (content.isEmpty) {
      throw const FormatException('Poem content is required');
    }
    if (languageCode.isEmpty) {
      throw const FormatException('Poem languageCode is required');
    }
    if (countryCode.isEmpty) {
      throw const FormatException('Poem countryCode is required');
    }
    if (sourceName.isEmpty) {
      throw const FormatException('Poem sourceName is required');
    }
    if (sourceUrl.isEmpty) {
      throw const FormatException('Poem sourceUrl is required');
    }
    if (rightsStatus.isEmpty) {
      throw const FormatException('Poem rightsStatus is required');
    }
  }
}
