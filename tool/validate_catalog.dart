import 'dart:io';

import 'catalog_validator.dart';

void main(List<String> arguments) {
  final poemsPath = _resolvePath(
    arguments,
    '--poems',
    'firebase/seed/poems.json',
  );
  final assignmentsPath = _resolvePath(
    arguments,
    '--assignments',
    'firebase/seed/daily_poems.json',
  );

  final result = CatalogValidator.validate(
    poemsPath: poemsPath,
    assignmentsPath: assignmentsPath,
  );

  stdout.writeln();
  stdout.writeln(result.summary.format());

  if (!result.isValid) {
    stdout.writeln('Validation FAILED — ${result.errors.length} error(s):');
    for (final error in result.errors) {
      stdout.writeln('  ERROR  $error');
    }
    exit(1);
  }

  stdout.writeln(
    'Validation PASSED — poem catalog structure is valid.\n'
    '  Human source and public-domain verification is still required\n'
    '  before production import.',
  );
}

String _resolvePath(List<String> arguments, String flag, String defaultPath) {
  final index = arguments.indexOf(flag);
  if (index == -1 || index + 1 >= arguments.length) return defaultPath;
  return arguments[index + 1];
}
