// Copyright 2026 Daily Stanza contributors.
// This script seeds the Firestore emulator with poem and daily-assignment data.
//
// Usage:
//   dart run tool/seed_firestore.dart
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

void main(List<String> arguments) async {
  const projectId = 'demo-daily-stanza';
  stdout.writeln('Targeting Firestore emulator on localhost:8080');

  const baseUrl =
      'http://localhost:8080/v1/projects/$projectId/databases/(default)'
      '/documents';

  // Read seed files.
  final poemsFile = File('firebase/seed/poems.json');
  final dailyFile = File('firebase/seed/daily_poems.json');

  if (!poemsFile.existsSync()) {
    stderr.writeln('Error: ${poemsFile.path} not found');
    exit(1);
  }
  if (!dailyFile.existsSync()) {
    stderr.writeln('Error: ${dailyFile.path} not found');
    exit(1);
  }

  final poems = _loadJsonArray(poemsFile);
  final dailyPoems = _loadJsonArray(dailyFile);

  // Validate.
  _validatePoems(poems);
  _validateDailyPoems(dailyPoems);
  _validateCrossReferences(poems, dailyPoems);

  // Write documents.
  final client = HttpClient();
  var written = 0;

  try {
    for (final poem in poems) {
      final id = poem['id'] as String;
      await _writeDocument(
        client: client,
        baseUrl: baseUrl,
        collection: 'poems',
        documentId: id,
        data: poem,
      );
      written++;
      stdout.writeln('  ✓ poems/$id');
    }

    for (final dp in dailyPoems) {
      final id = dp['id'] as String;
      await _writeDocument(
        client: client,
        baseUrl: baseUrl,
        collection: 'daily_poems',
        documentId: id,
        data: dp,
      );
      written++;
      stdout.writeln('  ✓ daily_poems/$id');
    }
  } finally {
    client.close();
  }

  stdout.writeln('\nDone. $written documents written.');
}

List<Map<String, dynamic>> _loadJsonArray(File file) {
  final content = file.readAsStringSync();
  final decoded = jsonDecode(content);
  if (decoded is! List) {
    stderr.writeln('Error: ${file.path} must be a JSON array');
    exit(1);
  }
  return decoded.cast<Map<String, dynamic>>();
}

void _validatePoems(List<Map<String, dynamic>> poems) {
  for (var i = 0; i < poems.length; i++) {
    final poem = poems[i];
    for (final field in _poemRequiredFields) {
      if (field == 'isApproved') {
        if (poem[field] is! bool || poem[field] != true) {
          stderr.writeln('Error: poems.json[$i] "$field" must be true');
          exit(1);
        }
      } else {
        if (poem[field] == null ||
            (poem[field] is String && (poem[field] as String).isEmpty)) {
          stderr.writeln(
            'Error: poems.json[$i] missing required field "$field"',
          );
          exit(1);
        }
      }
    }
  }
}

void _validateDailyPoems(List<Map<String, dynamic>> dailyPoems) {
  for (var i = 0; i < dailyPoems.length; i++) {
    final dp = dailyPoems[i];
    for (final field in _dailyRequiredFields) {
      if (field == 'isPublished') {
        if (dp[field] is! bool || dp[field] != true) {
          stderr.writeln('Error: daily_poems.json[$i] "$field" must be true');
          exit(1);
        }
      } else if (field == 'date') {
        final value = dp[field];
        if (value == null || value is! String || value.isEmpty) {
          stderr.writeln(
            'Error: daily_poems.json[$i] missing required field "$field"',
          );
          exit(1);
        }
        if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
          stderr.writeln(
            'Error: daily_poems.json[$i] "date" must be YYYY-MM-DD, '
            'got "$value"',
          );
          exit(1);
        }
      } else {
        if (dp[field] == null ||
            (dp[field] is String && (dp[field] as String).isEmpty)) {
          stderr.writeln(
            'Error: daily_poems.json[$i] missing required field "$field"',
          );
          exit(1);
        }
      }
    }
  }
}

void _validateCrossReferences(
  List<Map<String, dynamic>> poems,
  List<Map<String, dynamic>> dailyPoems,
) {
  final poemIds = poems.map((p) => p['id'] as String).toSet();
  for (var i = 0; i < dailyPoems.length; i++) {
    final poemId = dailyPoems[i]['poemId'] as String;
    if (!poemIds.contains(poemId)) {
      stderr.writeln(
        'Error: daily_poems.json[$i] references unknown poemId "$poemId"',
      );
      exit(1);
    }
  }
}

/// Converts a flat JSON map to Firestore REST API `fields` format.
Map<String, dynamic> _toFirestoreFields(Map<String, dynamic> data) {
  final fields = <String, dynamic>{};
  for (final entry in data.entries) {
    final key = entry.key;
    final value = entry.value;
    if (value is String) {
      fields[key] = {'stringValue': value};
    } else if (value is bool) {
      fields[key] = {'booleanValue': value};
    } else if (value is int) {
      fields[key] = {'integerValue': value.toString()};
    } else if (value is double) {
      fields[key] = {'doubleValue': value};
    } else if (value is List) {
      fields[key] = {
        'arrayValue': {'values': value.map(_toFirestoreValue).toList()},
      };
    } else if (value is Map) {
      fields[key] = {
        'mapValue': {
          'fields': _toFirestoreFields(value.cast<String, dynamic>()),
        },
      };
    } else {
      fields[key] = {'stringValue': value.toString()};
    }
  }
  return fields;
}

Map<String, dynamic> _toFirestoreValue(dynamic value) {
  if (value is String) return {'stringValue': value};
  if (value is bool) return {'booleanValue': value};
  if (value is int) return {'integerValue': value.toString()};
  if (value is double) return {'doubleValue': value};
  return {'stringValue': value.toString()};
}

Future<void> _writeDocument({
  required HttpClient client,
  required String baseUrl,
  required String collection,
  required String documentId,
  required Map<String, dynamic> data,
}) async {
  final url = '$baseUrl/$collection/$documentId';
  final fields = _toFirestoreFields(data);
  final body = jsonEncode({'fields': fields});

  final uri = Uri.parse(url);
  final request = await client.putUrl(uri);
  request.headers.contentType = ContentType.json;
  request.write(body);

  final response = await request.close();
  final statusCode = response.statusCode;

  // 200 = updated, 409 = already exists (ok for seeding)
  if (statusCode != 200 && statusCode != 409) {
    stderr.writeln('Error writing $collection/$documentId: HTTP $statusCode');
    response.transform(utf8.decoder).listen((body) {
      stderr.writeln('  $body');
    });
    exit(1);
  }
}
