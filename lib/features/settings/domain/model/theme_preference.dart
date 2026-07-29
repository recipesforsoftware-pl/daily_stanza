enum ThemePreference {
  system('system'),
  light('light'),
  dark('dark');

  const ThemePreference(this.code);

  final String code;

  static ThemePreference fromCode(String? code) {
    return switch (code) {
      'light' => ThemePreference.light,
      'dark' => ThemePreference.dark,
      _ => ThemePreference.system,
    };
  }
}
