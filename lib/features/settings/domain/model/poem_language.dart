enum PoemLanguage {
  english('en'),
  polish('pl');

  const PoemLanguage(this.code);

  final String code;

  static PoemLanguage fromCode(String? code) {
    return switch (code) {
      'pl' => PoemLanguage.polish,
      _ => PoemLanguage.english,
    };
  }
}
