// Copyright 2026 Daily Stanza contributors.
//
// Seeds the Firestore emulator with poem and daily-assignment data.
//
// Usage:
//   dart run tool/seed_firestore.dart
//   dart run tool/seed_firestore.dart --date 2026-07-28
//
// Requirements:
//   Start the Firestore emulator first:
//     firebase emulators:start --only firestore

import 'dart:convert';
import 'dart:io';

/// All required fields in poems.json entries.
const _poemRequiredFields = [
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
];

/// All required fields in daily_poems.json entries.
const _dailyRequiredFields = [
  'id',
  'date',
  'languageCode',
  'poemId',
  'isPublished',
];

Future<void> main(List<String> arguments) async {
  final date = _parseDate(arguments);
  final compactDate = _formatCompactDate(date);
  final isoDate = _formatIsoDate(date);

  const projectId = 'demo-daily-stanza';
  const emulatorHost = 'localhost';
  const emulatorPort = 8080;

  stdout.writeln('Targeting Firestore emulator on $emulatorHost:$emulatorPort');
  stdout.writeln('Using date: $isoDate');

  const baseUrl =
      'http://$emulatorHost:$emulatorPort/'
      'v1/projects/$projectId/databases/(default)/documents';

  final poemsFile = File('firebase/seed/poems.json');
  final dailyPoemsFile = File('firebase/seed/daily_poems.json');

  _ensureFileExists(poemsFile);
  _ensureFileExists(dailyPoemsFile);

  final poems = _loadJsonArray(poemsFile);
  final dailyPoems = _loadJsonArray(dailyPoemsFile);

  // Assignment document IDs use yyyyMMdd, while the stored date field
  // uses the ISO yyyy-MM-dd format.
  for (final dailyPoem in dailyPoems) {
    final languageCode = dailyPoem['languageCode'];

    if (languageCode is! String || languageCode.isEmpty) {
      stderr.writeln(
        'Error: daily poem assignment has an invalid languageCode',
      );
      exit(1);
    }

    dailyPoem['id'] = '${languageCode}_$compactDate';
    dailyPoem['date'] = isoDate;
  }

  _validatePoems(poems);
  _validateDailyPoems(dailyPoems);
  _validateCrossReferences(poems, dailyPoems);

  final client = HttpClient();
  var writtenDocuments = 0;

  try {
    for (final poem in poems) {
      final documentId = poem['id'] as String;

      await _writeDocument(
        client: client,
        baseUrl: baseUrl,
        collection: 'poems',
        documentId: documentId,
        data: poem,
      );

      writtenDocuments++;
      stdout.writeln('  ✓ poems/$documentId');
    }

    for (final dailyPoem in dailyPoems) {
      final documentId = dailyPoem['id'] as String;

      await _writeDocument(
        client: client,
        baseUrl: baseUrl,
        collection: 'daily_poems',
        documentId: documentId,
        data: dailyPoem,
      );

      writtenDocuments++;
      stdout.writeln('  ✓ daily_poems/$documentId');
    }
  } on SocketException catch (error) {
    stderr.writeln(
      '\nError: could not connect to the Firestore emulator at '
      '$emulatorHost:$emulatorPort.',
    );
    stderr.writeln(
      'Start it with: '
      'firebase emulators:start --only firestore',
    );
    stderr.writeln('Details: $error');
    exit(1);
  } finally {
    client.close(force: true);
  }

  stdout.writeln('\nDone. $writtenDocuments documents written.');
}

void _ensureFileExists(File file) {
  if (!file.existsSync()) {
    stderr.writeln('Error: ${file.path} not found');
    exit(1);
  }
}

DateTime _parseDate(List<String> arguments) {
  if (arguments.isEmpty) {
    return DateTime.now();
  }

  if (arguments.length != 2 || arguments.first != '--date') {
    stderr.writeln(
      'Error: unsupported arguments.\n'
      'Usage: dart run tool/seed_firestore.dart '
      '[--date YYYY-MM-DD]',
    );
    exit(1);
  }

  return _parseIsoDate(arguments[1]);
}

DateTime _parseIsoDate(String value) {
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);

  if (match == null) {
    stderr.writeln('Error: --date must be YYYY-MM-DD, got "$value"');
    exit(1);
  }

  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);

  final date = DateTime(year, month, day);

  // DateTime normalizes invalid dates, for example 2026-02-31.
  // Compare the resulting values to reject such input.
  if (date.year != year || date.month != month || date.day != day) {
    stderr.writeln('Error: --date is not a valid calendar date, got "$value"');
    exit(1);
  }

  return date;
}

String _formatCompactDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');

  return '$year$month$day';
}

String _formatIsoDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');

  return '$year-$month-$day';
}

List<Map<String, dynamic>> _loadJsonArray(File file) {
  try {
    final content = file.readAsStringSync();
    final decoded = jsonDecode(content);

    if (decoded is! List) {
      stderr.writeln('Error: ${file.path} must contain a JSON array');
      exit(1);
    }

    return decoded.map<Map<String, dynamic>>((entry) {
      if (entry is! Map<String, dynamic>) {
        stderr.writeln(
          'Error: every entry in ${file.path} must be a JSON object',
        );
        exit(1);
      }

      return Map<String, dynamic>.from(entry);
    }).toList();
  } on FormatException catch (error) {
    stderr.writeln(
      'Error: ${file.path} contains invalid JSON: ${error.message}',
    );
    exit(1);
  }
}

void _validatePoems(List<Map<String, dynamic>> poems) {
  for (var index = 0; index < poems.length; index++) {
    final poem = poems[index];

    for (final field in _poemRequiredFields) {
      if (field == 'isApproved') {
        if (poem[field] is! bool || poem[field] != true) {
          stderr.writeln('Error: poems.json[$index] "$field" must be true');
          exit(1);
        }

        continue;
      }

      final value = poem[field];

      if (value == null || (value is String && value.trim().isEmpty)) {
        stderr.writeln(
          'Error: poems.json[$index] '
          'missing required field "$field"',
        );
        exit(1);
      }
    }
  }
}

void _validateDailyPoems(List<Map<String, dynamic>> dailyPoems) {
  for (var index = 0; index < dailyPoems.length; index++) {
    final dailyPoem = dailyPoems[index];

    for (final field in _dailyRequiredFields) {
      if (field == 'isPublished') {
        if (dailyPoem[field] is! bool || dailyPoem[field] != true) {
          stderr.writeln(
            'Error: daily_poems.json[$index] '
            '"$field" must be true',
          );
          exit(1);
        }

        continue;
      }

      if (field == 'date') {
        final value = dailyPoem[field];

        if (value is! String || value.trim().isEmpty) {
          stderr.writeln(
            'Error: daily_poems.json[$index] '
            'missing required field "$field"',
          );
          exit(1);
        }

        if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
          stderr.writeln(
            'Error: daily_poems.json[$index] '
            '"date" must be YYYY-MM-DD, got "$value"',
          );
          exit(1);
        }

        continue;
      }

      final value = dailyPoem[field];

      if (value == null || (value is String && value.trim().isEmpty)) {
        stderr.writeln(
          'Error: daily_poems.json[$index] '
          'missing required field "$field"',
        );
        exit(1);
      }
    }
  }
}

void _validateCrossReferences(
  List<Map<String, dynamic>> poems,
  List<Map<String, dynamic>> dailyPoems,
) {
  final poemIds = poems.map((poem) => poem['id']).whereType<String>().toSet();

  for (var index = 0; index < dailyPoems.length; index++) {
    final poemId = dailyPoems[index]['poemId'];

    if (poemId is! String || !poemIds.contains(poemId)) {
      stderr.writeln(
        'Error: daily_poems.json[$index] '
        'references unknown poemId "$poemId"',
      );
      exit(1);
    }
  }
}

/// Converts a flat JSON map to the Firestore REST API `fields` format.
Map<String, dynamic> _toFirestoreFields(Map<String, dynamic> data) {
  final fields = <String, dynamic>{};

  for (final entry in data.entries) {
    fields[entry.key] = _toFirestoreValue(entry.value);
  }

  return fields;
}

Map<String, dynamic> _toFirestoreValue(dynamic value) {
  if (value == null) {
    return {'nullValue': null};
  }

  if (value is String) {
    return {'stringValue': value};
  }

  if (value is bool) {
    return {'booleanValue': value};
  }

  if (value is int) {
    return {'integerValue': value.toString()};
  }

  if (value is double) {
    return {'doubleValue': value};
  }

  if (value is List) {
    return {
      'arrayValue': {'values': value.map(_toFirestoreValue).toList()},
    };
  }

  if (value is Map) {
    return {
      'mapValue': {'fields': _toFirestoreFields(value.cast<String, dynamic>())},
    };
  }

  return {'stringValue': value.toString()};
}

Future<void> _writeDocument({
  required HttpClient client,
  required String baseUrl,
  required String collection,
  required String documentId,
  required Map<String, dynamic> data,
}) async {
  final encodedCollection = Uri.encodeComponent(collection);
  final encodedDocumentId = Uri.encodeComponent(documentId);

  final uri = Uri.parse('$baseUrl/$encodedCollection/$encodedDocumentId');

  final request = await client.patchUrl(uri);

  request.headers.contentType = ContentType.json;

  // Emulator-only administrator token.
  // It bypasses Firestore Security Rules when seeding local data.
  request.headers.set(HttpHeaders.authorizationHeader, 'Bearer owner');

  request.write(jsonEncode({'fields': _toFirestoreFields(data)}));

  final response = await request.close();
  final responseBody = await response.transform(utf8.decoder).join();

  if (response.statusCode != HttpStatus.ok) {
    stderr.writeln(
      'Error writing $collection/$documentId: '
      'HTTP ${response.statusCode}',
    );

    if (responseBody.isNotEmpty) {
      stderr.writeln('  $responseBody');
    }

    exit(1);
  }
}
