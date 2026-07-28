import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_stanza/features/daily_poem/data/dto/daily_poem_assignment_dto.dart';
import 'package:daily_stanza/features/daily_poem/data/dto/poem_dto.dart';
import 'package:daily_stanza/features/daily_poem/data/exception/poem_data_exception.dart';

class FirestorePoemDataSource {
  FirestorePoemDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  String _assignmentId({required DateTime date, required String languageCode}) {
    return DailyPoemAssignmentDto.generateId(
      date: date,
      languageCode: languageCode,
    );
  }

  /// Loads the daily assignment and referenced poem.
  ///
  /// Returns a tuple of (PoemDto, isFromCache).
  Future<(PoemDto, bool)> loadDailyPoem({
    required DateTime date,
    required String languageCode,
  }) async {
    try {
      final id = _assignmentId(date: date, languageCode: languageCode);

      // 1. Load daily assignment document.
      final assignmentRef = _firestore.collection('daily_poems').doc(id);
      final assignmentSnap = await assignmentRef.get();

      if (!assignmentSnap.exists) {
        throw const DailyPoemNotFoundException();
      }

      // 2. Parse and verify published.
      final assignmentDto = DailyPoemAssignmentDto.fromFirestore(
        assignmentSnap,
      );
      assignmentDto.validate();

      if (!assignmentDto.isPublished) {
        throw const AssignmentNotPublishedException();
      }

      // 3. Load referenced poem.
      final poemRef = _firestore.collection('poems').doc(assignmentDto.poemId);
      final poemSnap = await poemRef.get();

      if (!poemSnap.exists) {
        throw const PoemNotFoundException();
      }

      // 4. Parse and verify approved.
      final poemDto = PoemDto.fromFirestore(poemSnap);

      if (!poemDto.isApproved) {
        throw const PoemNotApprovedException();
      }

      // 5. Validate required fields.
      poemDto.validate();

      // 6. Determine if from cache.
      final isFromCache =
          assignmentSnap.metadata.isFromCache || poemSnap.metadata.isFromCache;

      return (poemDto, isFromCache);
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'permission-denied':
          throw const DataPermissionException();
        case 'unavailable':
          throw const DataUnavailableException();
        default:
          throw FirebaseDataException('Firestore error: ${e.code}');
      }
    }
  }

  /// Loads multiple poems by their IDs, preserving input order.
  ///
  /// Skips missing, unapproved, or invalid documents rather than throwing.
  Future<List<PoemDto>> loadPoemsByIds(List<String> poemIds) async {
    if (poemIds.isEmpty) return const [];

    try {
      final results = <PoemDto>[];

      for (final poemId in poemIds) {
        try {
          final doc = await _firestore.collection('poems').doc(poemId).get();
          if (!doc.exists) continue;

          final dto = PoemDto.fromFirestore(doc);
          if (!dto.isApproved) continue;

          dto.validate();
          results.add(dto);
        } on FormatException {
          // Skip this individual malformed document.
          continue;
        }
      }

      return results;
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'permission-denied':
          throw const DataPermissionException();
        case 'unavailable':
          throw const DataUnavailableException();
        default:
          throw FirebaseDataException('Firestore error: ${e.code}');
      }
    }
  }
}
