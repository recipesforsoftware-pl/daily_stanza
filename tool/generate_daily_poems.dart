import 'dart:convert';
import 'dart:io';

void main() {
  final poemsFile = File('firebase/seed/poems.json');
  final poems = _loadPoems(poemsFile);

  final enPoems = poems
      .where((p) => p['languageCode'] == 'en')
      .map((p) => p['id'] as String)
      .toList();
  final plPoems = poems
      .where((p) => p['languageCode'] == 'pl')
      .map((p) => p['id'] as String)
      .toList();

  if (enPoems.length != 8) {
    stderr.writeln('Error: expected 8 English poems, found ${enPoems.length}');
    exit(1);
  }
  if (plPoems.length != 8) {
    stderr.writeln('Error: expected 8 Polish poems, found ${plPoems.length}');
    exit(1);
  }

  final assignments = <Map<String, dynamic>>[];

  for (var i = 0; i < 365; i++) {
    final d = DateTime(2026, 7, 30 + i);
    final y = d.year.toString();
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    final compactDate = '$y$m$day';
    final isoDate = '$y-$m-$day';
    final enPoemIndex = i % 8;
    final plPoemIndex = i % 8;

    assignments.add({
      'id': 'en_$compactDate',
      'date': isoDate,
      'languageCode': 'en',
      'poemId': enPoems[enPoemIndex],
      'isPublished': true,
    });
    assignments.add({
      'id': 'pl_$compactDate',
      'date': isoDate,
      'languageCode': 'pl',
      'poemId': plPoems[plPoemIndex],
      'isPublished': true,
    });
  }

  final outputFile = File('firebase/seed/daily_poems.json');
  outputFile.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(assignments)}\n',
  );
}

List<Map<String, dynamic>> _loadPoems(File file) {
  if (!file.existsSync()) {
    stderr.writeln('Error: ${file.path} not found');
    exit(1);
  }
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
