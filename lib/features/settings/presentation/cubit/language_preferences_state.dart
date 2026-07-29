import 'package:equatable/equatable.dart';
import 'package:daily_stanza/features/settings/domain/model/poem_language.dart';

final class LanguagePreferencesState extends Equatable {
  const LanguagePreferencesState({
    required this.language,
    this.isSaving = false,
    this.mutationError,
  });

  final PoemLanguage language;
  final bool isSaving;

  /// One-time error message from a failed mutation.
  ///
  /// The global listener shows it via SnackBar.  The next emission clears it.
  final String? mutationError;

  LanguagePreferencesState copyWith({
    PoemLanguage? language,
    bool? isSaving,
    String? Function()? mutationError,
  }) {
    return LanguagePreferencesState(
      language: language ?? this.language,
      isSaving: isSaving ?? this.isSaving,
      mutationError: mutationError != null
          ? mutationError()
          : this.mutationError,
    );
  }

  @override
  List<Object?> get props => [language, isSaving, mutationError];
}
