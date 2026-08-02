import 'dart:io';

import 'catalog_provenance_validator.dart';

void main(List<String> arguments) {
  final provenancePath = _resolvePath(
    arguments,
    '--provenance',
    'firebase/seed/catalog_provenance.json',
  );
  final candidatesPath = _resolvePath(
    arguments,
    '--candidates',
    'firebase/seed/catalog_candidates.json',
  );

  final result = CatalogProvenanceValidator.validate(
    provenancePath: provenancePath,
    candidatesPath: candidatesPath,
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
    'Validation PASSED — provenance structure and classification '
    'consistency are valid.\n'
    '  Human source, edition, and legal review is still required before\n'
    '  poem texts are approved or imported into production.',
  );
}

String _resolvePath(List<String> arguments, String flag, String defaultPath) {
  final index = arguments.indexOf(flag);
  if (index == -1 || index + 1 >= arguments.length) return defaultPath;
  return arguments[index + 1];
}
