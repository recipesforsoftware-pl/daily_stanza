import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/daily_poem_assignment.dart';

class DailyPoemAssignmentDto {
  const DailyPoemAssignmentDto({
    required this.date,
    required this.languageCode,
    required this.poemId,
    required this.isPublished,
  });

  factory DailyPoemAssignmentDto.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw FormatException(
        'Daily poem assignment document ${doc.id} has no data',
      );
    }

    final dateRaw = data['date'];
    DateTime date;
    if (dateRaw is Timestamp) {
      date = dateRaw.toDate();
    } else if (dateRaw is String) {
      date = DateTime.parse(dateRaw);
    } else {
      throw const FormatException('Invalid date format in daily assignment');
    }

    return DailyPoemAssignmentDto(
      date: date,
      languageCode: data['languageCode'] as String? ?? '',
      poemId: data['poemId'] as String? ?? '',
      isPublished: data['isPublished'] as bool? ?? false,
    );
  }

  final DateTime date;
  final String languageCode;
  final String poemId;
  final bool isPublished;

  DailyPoemAssignment toDomain() {
    return DailyPoemAssignment(
      date: date,
      languageCode: languageCode,
      poemId: poemId,
      isPublished: isPublished,
    );
  }

  static String generateId({
    required DateTime date,
    required String languageCode,
  }) {
    final ymd =
        '${date.year.toString().padLeft(4, '0')}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}';
    return '${languageCode}_$ymd';
  }
}
