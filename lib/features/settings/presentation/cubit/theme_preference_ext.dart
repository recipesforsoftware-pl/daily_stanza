import 'package:flutter/material.dart';
import 'package:daily_stanza/features/settings/domain/model/theme_preference.dart';

ThemeMode toThemeMode(ThemePreference preference) {
  return switch (preference) {
    ThemePreference.system => ThemeMode.system,
    ThemePreference.light => ThemeMode.light,
    ThemePreference.dark => ThemeMode.dark,
  };
}
