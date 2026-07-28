// Copyright 2026 Daily Stanza contributors.
// This script seeds Firestore with poem and daily-assignment data.
//
// Usage:
//   dart run tool/seed_firestore.dart                   # emulator (default)
//   dart run tool/seed_firestore.dart --prod             # real Firebase project
//
// Requirements:
//   - For emulator: start `firebase emulators:start --only firestore`
//   - For --prod: run `flutterfire configure` first, then
//     set FIREBASE_PROJECT_ID env var or pass --project-id

import 'dart:convert';
import 'dart:io';

/// Minimum fields required in poems.json entries.
const _poemRequiredFields = [
  'title',
  'author',
  'languageCode',
  'countryCode',
  'content',
  'rightsStatus',
];

/// Minimum fields required in daily_poems.json entries.
const _dailyRequiredFields = ['date', 'languageCode', 'poemId'];

void main(List<String> arguments) async {
  var useProd = false;
  String? projectId;

  for (var i = 0; i < arguments.length; i++) {
    if (arguments[i] == '--prod') {
      useProd = true;
    } else if (arguments[i] == '--project-id' && i + 1 < arguments.length) {
      projectId = arguments[++i];
    }
  }

  if (useProd) {
    stdout.writeln(
      '⚠️  WARNING: You are about to write to a REAL Firebase project.',
    );
    projectId ??= Platform.environment['FIREBASE_PROJECT_ID'];
    if (projectId == null || projectId.isEmpty) {
      stderr.writeln(
        'Error: --prod requires a project ID.\n'
        '  Set FIREBASE_PROJECT_ID env var or pass --project-id <id>',
      );
      exit(1);
    }
    stdout.writeln('   Target project: $projectId');
    stdout.write('   Type "yes" to confirm: ');
    final confirm = stdin.readLineSync()?.trim();
    if (confirm != 'yes') {
      stdout.writeln('Aborted.');
      exit(0);
    }
  } else {
    projectId ??= 'daily-stanza-dev';
    stdout.writeln('Targeting Firestore emulator on localhost:8080');
  }

  final baseUrl = useProd
      ? 'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents'
      : 'http://localhost:8080/v1/projects/$projectId/databases/(default)/documents';

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

  // Write documents.
  final client = HttpClient();
  var written = 0;

  try {
    for (final poem in poems) {
      final id = _generatePoemId(poem);
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
      final id = _generateDailyId(dp);
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
      if (poem[field] == null ||
          (poem[field] is String && (poem[field] as String).isEmpty)) {
        stderr.writeln('Error: poems.json[$i] missing required field "$field"');
        exit(1);
      }
    }
  }
}

void _validateDailyPoems(List<Map<String, dynamic>> dailyPoems) {
  for (var i = 0; i < dailyPoems.length; i++) {
    final dp = dailyPoems[i];
    for (final field in _dailyRequiredFields) {
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

/// Generates a document ID from poem data: `{author}_{title}` slugified.
String _generatePoemId(Map<String, dynamic> poem) {
  final author = (poem['author'] as String)
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  final title = (poem['title'] as String)
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  return '${author}_$title';
}

/// Generates a daily-poem document ID: `{languageCode}_{yyyyMMdd}`.
String _generateDailyId(Map<String, dynamic> dp) {
  final lang = dp['languageCode'] as String;
  final date = dp['date'] as String;
  return '${lang}_$date';
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
    // Read response body for error details.
    response.transform(utf8.decoder).listen((body) {
      stderr.writeln('  $body');
    });
    exit(1);
  }
}
