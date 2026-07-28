sealed class DailyPoemFailure implements Exception {
  const DailyPoemFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class DailyPoemNotFoundFailure extends DailyPoemFailure {
  const DailyPoemNotFoundFailure([
    super.message = 'Daily poem assignment not found.',
  ]);
}

class PoemNotFoundFailure extends DailyPoemFailure {
  const PoemNotFoundFailure([super.message = 'Poem not found.']);
}

class InvalidPoemDataFailure extends DailyPoemFailure {
  const InvalidPoemDataFailure([
    super.message = 'Poem data is invalid or incomplete.',
  ]);
}

class PermissionFailure extends DailyPoemFailure {
  const PermissionFailure([super.message = 'Permission denied.']);
}

class NetworkFailure extends DailyPoemFailure {
  const NetworkFailure([
    super.message = 'Network error. Please check your connection.',
  ]);
}

class UnknownFailure extends DailyPoemFailure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}
