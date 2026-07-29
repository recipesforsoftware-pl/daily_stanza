import 'package:flutter/material.dart';
import 'package:daily_stanza/features/settings/domain/model/poem_language.dart';

class LanguageOptionTile extends StatelessWidget {
  const LanguageOptionTile({
    required this.language,
    required this.label,
    super.key,
  });

  final PoemLanguage language;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RadioListTile<PoemLanguage>(
      title: Text(label, style: theme.textTheme.bodyLarge),
      value: language,
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
