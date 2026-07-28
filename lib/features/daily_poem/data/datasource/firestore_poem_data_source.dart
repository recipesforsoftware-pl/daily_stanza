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
    final id = _assignmentId(date: date, languageCode: languageCode);

    // 1. Load daily assignment document.
    final assignmentRef = _firestore.collection('daily_poems').doc(id);
    final assignmentSnap = await assignmentRef.get();

    if (!assignmentSnap.exists) {
      throw const DailyPoemNotFoundException();
    }

    // 2. Parse and verify published.
    final assignmentDto = DailyPoemAssignmentDto.fromFirestore(assignmentSnap);

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
  }

  /// Loads multiple poems by their IDs.
  Future<List<PoemDto>> loadPoemsByIds(List<String> poemIds) async {
    if (poemIds.isEmpty) return const [];

    final results = <PoemDto>[];

    // Firestore 'in' queries support up to 30 items per batch.
    for (var i = 0; i < poemIds.length; i += 30) {
      final batch = poemIds.sublist(
        i,
        (i + 30 > poemIds.length) ? poemIds.length : i + 30,
      );

      final snapshot = await _firestore
          .collection('poems')
          .where(FieldPath.documentId, whereIn: batch)
          .get();

      for (final doc in snapshot.docs) {
        final dto = PoemDto.fromFirestore(doc);
        dto.validate();
        results.add(dto);
      }
    }

    return results;
  }
}
