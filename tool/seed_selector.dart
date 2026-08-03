// Copyright 2026 Daily Stanza contributors.
//
// Pure date-selection and validation helpers for the emulator seed tool.
//
// These functions perform no I/O and no Firestore access so they can be
// unit-tested without a running emulator.

import 'catalog_validator.dart';

/// Thrown when the catalog or the assignments for a selected date cannot be
/// turned into a valid seed plan.
class SeedSelectionException implements Exception {
  const SeedSelectionException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// The documents the seed tool will write: every poem plus only the
/// assignments for the selected date.
class SeedPlan {
  const SeedPlan({required this.poems, required this.assignments});

  /// All validated poems from poems.json.
  final List<Map<String, dynamic>> poems;

  /// Exactly two assignments (one English, one Polish) for the selected date,
  /// preserving their original ids and dates.
  final List<Map<String, dynamic>> assignments;
}

/// Validates the complete catalog, then selects the assignments for [isoDate].
///
/// Catalog validation always runs first, so a broken catalog is rejected
/// before any date selection or Firestore write happens.
SeedPlan buildSeedPlan({
  required List<Map<String, dynamic>> poems,
  required List<Map<String, dynamic>> assignments,
  required String isoDate,
}) {
  final catalogResult = CatalogValidator.validateData(
    poems: poems,
    assignments: assignments,
  );

  if (!catalogResult.isValid) {
    final firstErrors = catalogResult.errors.take(5).join('\n  ');
    throw SeedSelectionException(
      'Catalog validation failed with ${catalogResult.errors.length} '
      'error(s):\n  $firstErrors',
    );
  }

  final selected = selectDailyAssignments(assignments, isoDate: isoDate);

  return SeedPlan(poems: List.unmodifiable(poems), assignments: selected);
}

/// Selects the daily assignments whose date exactly matches [isoDate].
///
/// Preserves every original assignment id and date. Requires exactly one
/// English and one Polish assignment whose document IDs are
/// `en_YYYYMMDD` and `pl_YYYYMMDD`.
List<Map<String, dynamic>> selectDailyAssignments(
  List<Map<String, dynamic>> assignments, {
  required String isoDate,
}) {
  final compactDate = isoDate.replaceAll('-', '');

  final matching = assignments
      .where((assignment) => assignment['date'] == isoDate)
      .toList();

  final errors = <String>[];
  final byLanguage = <String, Map<String, dynamic>>{};
  final seenIds = <String>{};

  for (var index = 0; index < matching.length; index++) {
    final assignment = matching[index];
    final id = assignment['id'];
    final languageCode = assignment['languageCode'];

    if (languageCode is! String ||
        (languageCode != 'en' && languageCode != 'pl')) {
      errors.add(
        'assignment $index for $isoDate has malformed languageCode '
        '"$languageCode"',
      );
      continue;
    }

    if (id is! String || id != '${languageCode}_$compactDate') {
      errors.add(
        'assignment $index for $isoDate has id "$id", expected '
        '"${languageCode}_$compactDate"',
      );
    } else if (!seenIds.add(id)) {
      errors.add('duplicate assignment id "$id" for $isoDate');
    }

    if (byLanguage.containsKey(languageCode)) {
      errors.add('duplicate $languageCode assignment for $isoDate');
    } else {
      byLanguage[languageCode] = assignment;
    }
  }

  for (final language in const ['en', 'pl']) {
    if (!byLanguage.containsKey(language)) {
      errors.add('no $language assignment found for date $isoDate');
    }
  }

  if (errors.isNotEmpty) {
    throw SeedSelectionException(
      'No complete English and Polish assignment pair for date $isoDate:\n'
      '  ${errors.join('\n  ')}',
    );
  }

  return [byLanguage['en']!, byLanguage['pl']!];
}
