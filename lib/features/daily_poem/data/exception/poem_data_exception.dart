/// Data-layer exceptions thrown by [FirestorePoemDataSource].
///
/// These exceptions stay within the data layer. The repository maps them
/// to domain [DailyPoemFailure] subclasses so Firebase types never leak.
sealed class PoemDataException implements Exception {
  const PoemDataException(this.message);

  final String message;

  @override
  String toString() => message;
}

class DailyPoemNotFoundException extends PoemDataException {
  const DailyPoemNotFoundException([
    super.message = 'Daily poem assignment not found.',
  ]);
}

class AssignmentNotPublishedException extends PoemDataException {
  const AssignmentNotPublishedException([
    super.message = 'Assignment is not published.',
  ]);
}

class PoemNotFoundException extends PoemDataException {
  const PoemNotFoundException([super.message = 'Poem not found.']);
}

class PoemNotApprovedException extends PoemDataException {
  const PoemNotApprovedException([super.message = 'Poem is not approved.']);
}
