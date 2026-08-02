import 'dart:convert';
import 'dart:io';

class CatalogValidationError {
  const CatalogValidationError(this.record, this.field, this.message);

  final String record;
  final String field;
  final String message;

  @override
  String toString() => '$record: $field — $message';
}

class CatalogSummary {
  const CatalogSummary({
    required this.totalPoems,
    required this.englishPoems,
    required this.polishPoems,
    required this.totalAssignments,
    this.earliestDate,
    this.latestDate,
  });

  final int totalPoems;
  final int englishPoems;
  final int polishPoems;
  final int totalAssignments;
  final String? earliestDate;
  final String? latestDate;

  String format() {
    final buffer = StringBuffer();
    buffer.writeln('Catalog Summary');
    buffer.writeln(
      '  Poems:              $totalPoems total, '
      '$englishPoems English, $polishPoems Polish',
    );
    buffer.writeln('  Assignments:        $totalAssignments');
    if (earliestDate != null && latestDate != null) {
      buffer.writeln('  Date range:         $earliestDate – $latestDate');
    }
    return buffer.toString();
  }
}

class CatalogValidationResult {
  const CatalogValidationResult({required this.errors, required this.summary});

  final List<CatalogValidationError> errors;
  final CatalogSummary summary;

  bool get isValid => errors.isEmpty;
}

class CatalogValidator {
  CatalogValidator._();

  static const _knownPoemFields = <String>{
    'id',
    'title',
    'author',
    'languageCode',
    'countryCode',
    'content',
    'sourceName',
    'sourceUrl',
    'rightsStatus',
    'isApproved',
  };

  static const _supportedLanguages = <String>{'en', 'pl'};

  static final _placeholderPatterns = <RegExp>[
    RegExp(r'lorem ipsum', caseSensitive: false),
    RegExp(r'\bTODO\b'),
    RegExp(r'\bTBD\b'),
    RegExp(r'your poem here', caseSensitive: false),
    RegExp(r'placeholder', caseSensitive: false),
    RegExp(r'sample text', caseSensitive: false),
  ];

  static CatalogValidationResult validate({
    required String poemsPath,
    required String assignmentsPath,
  }) {
    final poemsFile = File(poemsPath);
    final assignmentsFile = File(assignmentsPath);

    if (!poemsFile.existsSync()) {
      stderr.writeln('Error: poems file not found at $poemsPath');
      exit(1);
    }
    if (!assignmentsFile.existsSync()) {
      stderr.writeln('Error: assignments file not found at $assignmentsPath');
      exit(1);
    }

    final poems = _loadJsonArray(poemsFile);
    final assignments = _loadJsonArray(assignmentsFile);

    return validateData(poems: poems, assignments: assignments);
  }

  static CatalogValidationResult validateData({
    required List<Map<String, dynamic>> poems,
    required List<Map<String, dynamic>> assignments,
  }) {
    final errors = <CatalogValidationError>[];
    errors.addAll(_validatePoems(poems));
    errors.addAll(_validateAssignments(assignments));
    errors.addAll(_validateCrossReferences(poems, assignments));
    errors.addAll(_validateCatalogInvariants(poems, assignments));

    final summary = _buildSummary(poems, assignments);

    return CatalogValidationResult(errors: errors, summary: summary);
  }

  static List<Map<String, dynamic>> _loadJsonArray(File file) {
    try {
      final decoded = jsonDecode(file.readAsStringSync());
      if (decoded is! List) {
        stderr.writeln('Error: ${file.path} must contain a JSON array');
        exit(1);
      }
      return decoded.cast<Map<String, dynamic>>();
    } on FormatException catch (e) {
      stderr.writeln('Error: ${file.path} invalid JSON: ${e.message}');
      exit(1);
    }
  }

  static List<CatalogValidationError> _validatePoems(
    List<Map<String, dynamic>> poems,
  ) {
    final errors = <CatalogValidationError>[];
    final ids = <String>{};

    for (var i = 0; i < poems.length; i++) {
      final p = poems[i];
      final prefix = 'poems[$i]';
      final id = _asString(p['id']);

      if (id.isEmpty) {
        errors.add(CatalogValidationError(prefix, 'id', 'must not be empty'));
      } else if (!ids.add(id)) {
        errors.add(
          CatalogValidationError(prefix, 'id', 'duplicate poem ID "$id"'),
        );
      }

      final title = _asString(p['title']);
      if (title.isEmpty) {
        errors.add(
          CatalogValidationError(prefix, 'title', 'must not be empty'),
        );
      }

      final author = _asString(p['author']);
      if (author.isEmpty) {
        errors.add(
          CatalogValidationError(prefix, 'author', 'must not be empty'),
        );
      }

      final languageCode = _asString(p['languageCode']);
      if (!_supportedLanguages.contains(languageCode)) {
        errors.add(
          CatalogValidationError(
            prefix,
            'languageCode',
            'must be "en" or "pl", got "$languageCode"',
          ),
        );
      }

      final countryCode = _asString(p['countryCode']);
      if (!RegExp(r'^[A-Z]{2}$').hasMatch(countryCode)) {
        errors.add(
          CatalogValidationError(
            prefix,
            'countryCode',
            'must be exactly two uppercase letters [A-Z], got "$countryCode"',
          ),
        );
      }

      final content = _asString(p['content']);
      if (content.isEmpty) {
        errors.add(
          CatalogValidationError(prefix, 'content', 'must not be empty'),
        );
      } else if (_isPlaceholder(content)) {
        errors.add(
          CatalogValidationError(
            prefix,
            'content',
            'appears to be placeholder text',
          ),
        );
      }

      final sourceName = _asString(p['sourceName']);
      if (sourceName.isEmpty) {
        errors.add(
          CatalogValidationError(prefix, 'sourceName', 'must not be empty'),
        );
      }

      if (p.containsKey('sourceUrl')) {
        final sourceUrl = _asString(p['sourceUrl']);
        if (sourceUrl.isNotEmpty && !_isValidHttpsUrl(sourceUrl)) {
          errors.add(
            CatalogValidationError(
              prefix,
              'sourceUrl',
              'must be a valid HTTPS URL, got "$sourceUrl"',
            ),
          );
        }
      }

      final rightsStatus = _asString(p['rightsStatus']);
      if (rightsStatus != 'public_domain') {
        errors.add(
          CatalogValidationError(
            prefix,
            'rightsStatus',
            'must be "public_domain", got "$rightsStatus"',
          ),
        );
      }

      if (p['isApproved'] != true) {
        errors.add(
          CatalogValidationError(prefix, 'isApproved', 'must be true'),
        );
      }

      for (final key in p.keys) {
        if (!_knownPoemFields.contains(key)) {
          errors.add(
            CatalogValidationError(prefix, key, 'unknown field "$key"'),
          );
        }
      }
    }

    return errors;
  }

  static List<CatalogValidationError> _validateAssignments(
    List<Map<String, dynamic>> assignments,
  ) {
    final errors = <CatalogValidationError>[];
    final ids = <String>{};
    final dateLanguageKeys = <String>{};

    for (var i = 0; i < assignments.length; i++) {
      final a = assignments[i];
      final prefix = 'assignments[$i]';
      final id = _asString(a['id']);

      if (id.isEmpty) {
        errors.add(CatalogValidationError(prefix, 'id', 'must not be empty'));
      } else if (!ids.add(id)) {
        errors.add(
          CatalogValidationError(prefix, 'id', 'duplicate assignment ID "$id"'),
        );
      }

      final idMatch = RegExp(r'^(en|pl)_(\d{4})(\d{2})(\d{2})$').firstMatch(id);

      if (idMatch == null) {
        errors.add(
          CatalogValidationError(
            prefix,
            'id',
            'must match en_yyyyMMdd or pl_yyyyMMdd, got "$id"',
          ),
        );
      }

      final dateStr = _asString(a['date']);
      final dateMatch = RegExp(
        r'^(\d{4})-(\d{2})-(\d{2})$',
      ).firstMatch(dateStr);

      if (dateMatch == null) {
        errors.add(
          CatalogValidationError(
            prefix,
            'date',
            'must be yyyy-MM-dd, got "$dateStr"',
          ),
        );
      }

      final languageCode = _asString(a['languageCode']);
      if (!_supportedLanguages.contains(languageCode)) {
        errors.add(
          CatalogValidationError(
            prefix,
            'languageCode',
            'must be "en" or "pl", got "$languageCode"',
          ),
        );
      }

      final poemId = _asString(a['poemId']);
      if (poemId.isEmpty) {
        errors.add(
          CatalogValidationError(prefix, 'poemId', 'must not be empty'),
        );
      }

      if (a['isPublished'] != true) {
        errors.add(
          CatalogValidationError(prefix, 'isPublished', 'must be true'),
        );
      }

      if (idMatch != null && dateMatch != null) {
        final idLang = idMatch.group(1)!;
        final idYear = idMatch.group(2)!;
        final idMonth = idMatch.group(3)!;
        final idDay = idMatch.group(4)!;
        final idDate = '$idYear-$idMonth-$idDay';

        if (idDate != dateStr) {
          errors.add(
            CatalogValidationError(
              prefix,
              'id/date',
              'ID date "$idDate" does not match date field "$dateStr"',
            ),
          );
        }

        if (idLang != languageCode) {
          errors.add(
            CatalogValidationError(
              prefix,
              'id/languageCode',
              'ID language "$idLang" does not match languageCode "$languageCode"',
            ),
          );
        }
      }

      final dlKey = '${languageCode}_${dateStr}';
      if (languageCode.isNotEmpty && dateStr.isNotEmpty) {
        if (!dateLanguageKeys.add(dlKey)) {
          errors.add(
            CatalogValidationError(
              prefix,
              'date+languageCode',
              'duplicate assignment for $dlKey',
            ),
          );
        }
      }
    }

    return errors;
  }

  static List<CatalogValidationError> _validateCrossReferences(
    List<Map<String, dynamic>> poems,
    List<Map<String, dynamic>> assignments,
  ) {
    final errors = <CatalogValidationError>[];
    final poemMap = <String, Map<String, dynamic>>{};

    for (final p in poems) {
      final id = _asString(p['id']);
      if (id.isNotEmpty) {
        poemMap[id] = p;
      }
    }

    for (var i = 0; i < assignments.length; i++) {
      final a = assignments[i];
      final poemId = _asString(a['poemId']);
      final lang = _asString(a['languageCode']);

      if (poemId.isEmpty) continue;

      if (!poemMap.containsKey(poemId)) {
        errors.add(
          CatalogValidationError(
            'assignments[$i]',
            'poemId',
            'references unknown poem "$poemId"',
          ),
        );
        continue;
      }

      final poemLang = _asString(poemMap[poemId]!['languageCode']);
      if (lang.isNotEmpty && poemLang.isNotEmpty && lang != poemLang) {
        errors.add(
          CatalogValidationError(
            'assignments[$i]',
            'languageCode',
            'assignment language "$lang" does not match poem '
                '"$poemId" language "$poemLang"',
          ),
        );
      }
    }

    return errors;
  }

  static List<CatalogValidationError> _validateCatalogInvariants(
    List<Map<String, dynamic>> poems,
    List<Map<String, dynamic>> assignments,
  ) {
    final errors = <CatalogValidationError>[];

    if (poems.length != 16) {
      errors.add(
        CatalogValidationError(
          'catalog',
          'poems.count',
          'expected exactly 16 poems, got ${poems.length}',
        ),
      );
    }

    var enCount = 0;
    var plCount = 0;
    for (final p in poems) {
      final lang = _asString(p['languageCode']);
      if (lang == 'en') enCount++;
      if (lang == 'pl') plCount++;
    }
    if (enCount != 8) {
      errors.add(
        CatalogValidationError(
          'catalog',
          'poems.english',
          'expected exactly 8 English poems, got $enCount',
        ),
      );
    }
    if (plCount != 8) {
      errors.add(
        CatalogValidationError(
          'catalog',
          'poems.polish',
          'expected exactly 8 Polish poems, got $plCount',
        ),
      );
    }

    if (assignments.length != 730) {
      errors.add(
        CatalogValidationError(
          'catalog',
          'assignments.count',
          'expected exactly 730 assignments, got ${assignments.length}',
        ),
      );
    }

    var enAssign = 0;
    var plAssign = 0;
    for (final a in assignments) {
      final lang = _asString(a['languageCode']);
      if (lang == 'en') enAssign++;
      if (lang == 'pl') plAssign++;
    }
    if (enAssign != 365) {
      errors.add(
        CatalogValidationError(
          'catalog',
          'assignments.english',
          'expected exactly 365 English assignments, got $enAssign',
        ),
      );
    }
    if (plAssign != 365) {
      errors.add(
        CatalogValidationError(
          'catalog',
          'assignments.polish',
          'expected exactly 365 Polish assignments, got $plAssign',
        ),
      );
    }

    var earliest = '';
    var latest = '';
    for (final a in assignments) {
      final date = _asString(a['date']);
      if (date.isEmpty) continue;
      if (earliest.isEmpty || date.compareTo(earliest) < 0) earliest = date;
      if (latest.isEmpty || date.compareTo(latest) > 0) latest = date;
    }

    if (earliest != '2026-07-30') {
      errors.add(
        CatalogValidationError(
          'catalog',
          'assignments.date_range',
          'expected earliest date 2026-07-30, got "$earliest"',
        ),
      );
    }
    if (latest != '2027-07-29') {
      errors.add(
        CatalogValidationError(
          'catalog',
          'assignments.date_range',
          'expected latest date 2027-07-29, got "$latest"',
        ),
      );
    }

    final usedPoems = <String>{};
    for (final a in assignments) {
      final pid = _asString(a['poemId']);
      if (pid.isNotEmpty) usedPoems.add(pid);
    }
    for (final p in poems) {
      final pid = _asString(p['id']);
      if (pid.isNotEmpty && !usedPoems.contains(pid)) {
        errors.add(
          CatalogValidationError(
            'catalog',
            'poem.never_used',
            'poem "$pid" is never assigned in daily_poems',
          ),
        );
      }
    }

    return errors;
  }

  static CatalogSummary _buildSummary(
    List<Map<String, dynamic>> poems,
    List<Map<String, dynamic>> assignments,
  ) {
    var english = 0;
    var polish = 0;

    for (final p in poems) {
      final lang = _asString(p['languageCode']);
      if (lang == 'en') english++;
      if (lang == 'pl') polish++;
    }

    String? earliest;
    String? latest;

    for (final a in assignments) {
      final date = _asString(a['date']);
      if (date.isEmpty) continue;
      if (earliest == null || date.compareTo(earliest) < 0) earliest = date;
      if (latest == null || date.compareTo(latest) > 0) latest = date;
    }

    return CatalogSummary(
      totalPoems: poems.length,
      englishPoems: english,
      polishPoems: polish,
      totalAssignments: assignments.length,
      earliestDate: earliest,
      latestDate: latest,
    );
  }

  static String _asString(dynamic value) {
    if (value is String) return value;
    return '';
  }

  static bool _isPlaceholder(String content) {
    if (content.trim().isEmpty) return true;
    for (final pattern in _placeholderPatterns) {
      if (pattern.hasMatch(content)) return true;
    }
    return false;
  }

  static bool _isValidHttpsUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty;
  }
}
