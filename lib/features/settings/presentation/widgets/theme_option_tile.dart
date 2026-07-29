import 'package:flutter/material.dart';
import 'package:daily_stanza/features/settings/domain/model/theme_preference.dart';

class ThemeOptionTile extends StatelessWidget {
  const ThemeOptionTile({
    required this.preference,
    required this.label,
    required this.description,
    super.key,
  });

  final ThemePreference preference;
  final String label;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RadioListTile<ThemePreference>(
      title: Text(label, style: theme.textTheme.bodyLarge),
      subtitle: Text(
        description,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      value: preference,
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
