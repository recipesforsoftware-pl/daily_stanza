import 'dart:convert';
import 'dart:io';

class ProvenanceValidationError {
  const ProvenanceValidationError(this.record, this.field, this.message);

  final String record;
  final String field;
  final String message;

  @override
  String toString() => '$record: $field — $message';
}

class ProvenanceSummary {
  const ProvenanceSummary({
    required this.totalRecords,
    required this.publicDomainCandidates,
    required this.manualLegalReviewRecords,
    required this.replacementCandidates,
    required this.rejectedSources,
    required this.incompleteChecksRecords,
    required this.englishRecords,
    required this.polishRecords,
    this.deathYearRange,
  });

  final int totalRecords;
  final int publicDomainCandidates;
  final int manualLegalReviewRecords;
  final int replacementCandidates;
  final int rejectedSources;
  final int incompleteChecksRecords;
  final int englishRecords;
  final int polishRecords;
  final String? deathYearRange;

  String format() {
    final buffer = StringBuffer();
    buffer.writeln('Catalog Provenance Summary');
    buffer.writeln('  Total records:                  $totalRecords');
    buffer.writeln('  Public-domain candidates:       $publicDomainCandidates');
    buffer.writeln(
      '  Manual legal review required:   $manualLegalReviewRecords',
    );
    buffer.writeln('  Replacement candidates:         $replacementCandidates');
    buffer.writeln('  Rejected sources:               $rejectedSources');
    buffer.writeln(
      '  English / Polish:               $englishRecords / $polishRecords',
    );
    buffer.writeln(
      '  Records with incomplete checks: $incompleteChecksRecords',
    );
    if (deathYearRange != null) {
      buffer.writeln('  Death year range:               $deathYearRange');
    }
    return buffer.toString();
  }
}

class ProvenanceValidationResult {
  const ProvenanceValidationResult({
    required this.errors,
    required this.summary,
  });

  final List<ProvenanceValidationError> errors;
  final ProvenanceSummary summary;

  bool get isValid => errors.isEmpty;
}

class CatalogProvenanceValidator {
  CatalogProvenanceValidator._();

  static const _knownRecordFields = <String>{
    'candidateId',
    'authorDeathYear',
    'authorDeathYearSourceUrl',
    'sourceUrl',
    'sourceRightsEvidenceUrl',
    'sourceRetrievalDate',
    'rightsStatusCandidate',
    'reviewStatus',
    'automatedChecks',
    'reviewNotes',
  };

  static const _knownCheckFields = <String>{
    'sourceReachable',
    'titleMatched',
    'authorMatched',
    'languageMatched',
    'noTranslationDetected',
    'editionIdentified',
    'deathYearRecorded',
    'exactTextSourceAvailable',
    'rightsNoticeLocated',
  };

  static const _requiredChecksForPublicDomainCandidate = <String>{
    'sourceReachable',
    'titleMatched',
    'authorMatched',
    'languageMatched',
    'noTranslationDetected',
    'editionIdentified',
    'deathYearRecorded',
    'exactTextSourceAvailable',
    'rightsNoticeLocated',
  };

  static const _allowedRightsStatus = <String>{
    'public_domain_candidate',
    'required_manual_legal_review',
    'rejected',
  };

  static const _allowedReviewStatus = <String>{
    'pending_human_review',
    'replacement_candidate_required',
    'rejected_source',
  };

  static ProvenanceValidationResult validate({
    required String provenancePath,
    required String candidatesPath,
  }) {
    final provenanceFile = File(provenancePath);
    final candidatesFile = File(candidatesPath);

    if (!provenanceFile.existsSync()) {
      stderr.writeln('Error: provenance file not found at $provenancePath');
      exit(1);
    }
    if (!candidatesFile.existsSync()) {
      stderr.writeln('Error: candidates file not found at $candidatesPath');
      exit(1);
    }

    final provenance = _loadProvenance(provenanceFile);
    final candidateInfo = _loadCandidateInfo(candidatesFile);

    return validateData(
      provenance: provenance,
      candidateIds: candidateInfo.keys.toSet(),
      candidateLanguages: candidateInfo,
    );
  }

  static Map<String, dynamic> _loadProvenance(File file) {
    try {
      final decoded = jsonDecode(file.readAsStringSync());
      if (decoded is! Map) {
        stderr.writeln('Error: ${file.path} must be a JSON object');
        exit(1);
      }
      return decoded as Map<String, dynamic>;
    } on FormatException catch (e) {
      stderr.writeln('Error: ${file.path} invalid JSON: ${e.message}');
      exit(1);
    }
  }

  static Map<String, String> _loadCandidateInfo(File file) {
    try {
      final decoded = jsonDecode(file.readAsStringSync());
      if (decoded is! Map) {
        stderr.writeln('Error: ${file.path} must be a JSON object');
        exit(1);
      }
      final map = decoded as Map<String, dynamic>;
      final list = map['candidates'] as List?;
      if (list == null) {
        stderr.writeln('Error: ${file.path} missing "candidates" key');
        exit(1);
      }
      final result = <String, String>{};
      for (final c in list.cast<Map<String, dynamic>>()) {
        final id = c['id'] as String? ?? '';
        final lang = c['languageCode'] as String? ?? '';
        if (id.isNotEmpty) result[id] = lang;
      }
      return result;
    } on FormatException catch (e) {
      stderr.writeln('Error: ${file.path} invalid JSON: ${e.message}');
      exit(1);
    }
  }

  static ProvenanceValidationResult validateData({
    required Map<String, dynamic> provenance,
    required Set<String> candidateIds,
    Map<String, String> candidateLanguages = const {},
  }) {
    final errors = <ProvenanceValidationError>[];
    final records = provenance['records'] as List?;

    if (records == null) {
      errors.add(
        const ProvenanceValidationError(
          '_root',
          'records',
          'missing "records" array',
        ),
      );
      return ProvenanceValidationResult(
        errors: errors,
        summary: _emptySummary(),
      );
    }

    if (provenance['schemaVersion'] != 1) {
      errors.add(
        const ProvenanceValidationError('_root', 'schemaVersion', 'must be 1'),
      );
    }

    final purpose = provenance['purpose'];
    if (purpose == null || (purpose is! String) || purpose.isEmpty) {
      errors.add(
        const ProvenanceValidationError(
          '_root',
          'purpose',
          'must not be empty',
        ),
      );
    }

    final recordList = records.cast<Map<String, dynamic>>();
    final recordedIds = <String>{};
    var publicDomainCandidates = 0;
    var manualLegalReviewRecords = 0;
    var replacementCandidates = 0;
    var rejectedSources = 0;
    var incompleteChecksRecords = 0;
    var minDeathYear = 9999;
    var maxDeathYear = 0;
    var enCount = 0;
    var plCount = 0;

    for (var i = 0; i < recordList.length; i++) {
      final r = recordList[i];
      final prefix = 'records[$i]';

      final cid = _asString(r['candidateId']);
      if (cid.isEmpty) {
        errors.add(
          ProvenanceValidationError(prefix, 'candidateId', 'must not be empty'),
        );
      } else {
        if (!recordedIds.add(cid)) {
          errors.add(
            ProvenanceValidationError(
              prefix,
              'candidateId',
              'duplicate "$cid"',
            ),
          );
        }
        if (!candidateIds.contains(cid)) {
          errors.add(
            ProvenanceValidationError(
              prefix,
              'candidateId',
              '"$cid" not found in catalog_candidates.json',
            ),
          );
        }
      }

      final deathYear = r['authorDeathYear'];
      if (deathYear is! int || deathYear < 1500 || deathYear > 2026) {
        errors.add(
          ProvenanceValidationError(
            prefix,
            'authorDeathYear',
            'must be a plausible year (1500–2026)',
          ),
        );
      } else {
        if (deathYear < minDeathYear) minDeathYear = deathYear;
        if (deathYear > maxDeathYear) maxDeathYear = deathYear;
        if (deathYear + 70 >= 2026) {
          errors.add(
            ProvenanceValidationError(
              prefix,
              'authorDeathYear',
              'author died $deathYear, Life+70 not yet expired '
                  '(expires ${deathYear + 70})',
            ),
          );
        }
      }

      final deathUrl = _asString(r['authorDeathYearSourceUrl']);
      if (deathUrl.isEmpty) {
        errors.add(
          ProvenanceValidationError(
            prefix,
            'authorDeathYearSourceUrl',
            'must not be empty',
          ),
        );
      } else if (!_isValidHttpsUrl(deathUrl)) {
        errors.add(
          ProvenanceValidationError(
            prefix,
            'authorDeathYearSourceUrl',
            'must be a valid HTTPS URL',
          ),
        );
      }

      final sourceUrl = _asString(r['sourceUrl']);
      if (sourceUrl.isEmpty) {
        errors.add(
          ProvenanceValidationError(prefix, 'sourceUrl', 'must not be empty'),
        );
      } else if (!_isValidHttpsUrl(sourceUrl)) {
        errors.add(
          ProvenanceValidationError(
            prefix,
            'sourceUrl',
            'must be a valid HTTPS URL',
          ),
        );
      }

      final retrievalDate = _asString(r['sourceRetrievalDate']);
      if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(retrievalDate)) {
        errors.add(
          ProvenanceValidationError(
            prefix,
            'sourceRetrievalDate',
            'must be yyyy-MM-dd',
          ),
        );
      }

      final rightsStatus = _asString(r['rightsStatusCandidate']);
      if (!_allowedRightsStatus.contains(rightsStatus)) {
        errors.add(
          ProvenanceValidationError(
            prefix,
            'rightsStatusCandidate',
            'must be one of ${_allowedRightsStatus.join(", ")}, got "$rightsStatus"',
          ),
        );
      } else {
        if (rightsStatus == 'public_domain_candidate') {
          publicDomainCandidates++;
        } else if (rightsStatus == 'required_manual_legal_review') {
          manualLegalReviewRecords++;
        } else if (rightsStatus == 'rejected') {
          rejectedSources++;
        }
      }

      final reviewStatus = _asString(r['reviewStatus']);
      if (!_allowedReviewStatus.contains(reviewStatus)) {
        errors.add(
          ProvenanceValidationError(
            prefix,
            'reviewStatus',
            'must be one of ${_allowedReviewStatus.join(", ")}, got "$reviewStatus"',
          ),
        );
      } else {
        if (reviewStatus == 'replacement_candidate_required') {
          replacementCandidates++;
        } else if (reviewStatus == 'rejected_source') {
          rejectedSources++;
        }
      }

      final checks = r['automatedChecks'];
      if (checks is! Map) {
        errors.add(
          ProvenanceValidationError(prefix, 'automatedChecks', 'must be a map'),
        );
      } else {
        final checkMap = checks as Map<String, dynamic>;
        for (final field in _knownCheckFields) {
          if (checkMap[field] is! bool) {
            errors.add(
              ProvenanceValidationError(
                prefix,
                'automatedChecks.$field',
                'must be a boolean',
              ),
            );
          }
        }
        for (final key in checkMap.keys) {
          if (!_knownCheckFields.contains(key)) {
            errors.add(
              ProvenanceValidationError(
                prefix,
                'automatedChecks.$key',
                'unknown field',
              ),
            );
          }
        }

        final falseChecks = _knownCheckFields.where((f) => checkMap[f] != true);
        if (falseChecks.isNotEmpty) {
          incompleteChecksRecords++;
        }

        // Classification consistency: public_domain_candidate requires all
        // relevant checks to be true.
        if (rightsStatus == 'public_domain_candidate') {
          for (final field in _requiredChecksForPublicDomainCandidate) {
            if (checkMap[field] != true) {
              errors.add(
                ProvenanceValidationError(
                  prefix,
                  'automatedChecks.$field',
                  'must be true when rightsStatusCandidate is '
                      'public_domain_candidate',
                ),
              );
            }
          }
        }
      }

      final notes = _asString(r['reviewNotes']);
      if (notes.isEmpty) {
        errors.add(
          ProvenanceValidationError(prefix, 'reviewNotes', 'must not be empty'),
        );
      }

      for (final key in r.keys) {
        if (!_knownRecordFields.contains(key)) {
          errors.add(
            ProvenanceValidationError(prefix, key, 'unknown field "$key"'),
          );
        }
      }

      final lang = candidateLanguages[cid] ?? cid.split('_').first;
      if (lang == 'en')
        enCount++;
      else if (lang == 'pl')
        plCount++;
    }

    final deathYearRange = minDeathYear <= maxDeathYear
        ? '$minDeathYear – $maxDeathYear'
        : null;

    final summary = ProvenanceSummary(
      totalRecords: recordList.length,
      publicDomainCandidates: publicDomainCandidates,
      manualLegalReviewRecords: manualLegalReviewRecords,
      replacementCandidates: replacementCandidates,
      rejectedSources: rejectedSources,
      incompleteChecksRecords: incompleteChecksRecords,
      englishRecords: enCount,
      polishRecords: plCount,
      deathYearRange: deathYearRange,
    );

    return ProvenanceValidationResult(errors: errors, summary: summary);
  }

  static ProvenanceSummary _emptySummary() => const ProvenanceSummary(
    totalRecords: 0,
    publicDomainCandidates: 0,
    manualLegalReviewRecords: 0,
    replacementCandidates: 0,
    rejectedSources: 0,
    incompleteChecksRecords: 0,
    englishRecords: 0,
    polishRecords: 0,
  );

  static String _asString(dynamic value) {
    if (value is String) return value;
    return '';
  }

  static bool _isValidHttpsUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty;
  }
}
