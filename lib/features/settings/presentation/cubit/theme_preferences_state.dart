import 'package:equatable/equatable.dart';
import 'package:daily_stanza/features/settings/domain/model/theme_preference.dart';

final class ThemePreferencesState extends Equatable {
  const ThemePreferencesState({
    required this.preference,
    this.isSaving = false,
    this.mutationError,
  });

  final ThemePreference preference;
  final bool isSaving;

  /// One-time error message from a failed mutation.
  ///
  /// The global listener shows it via SnackBar.  The next emission clears it.
  final String? mutationError;

  ThemePreferencesState copyWith({
    ThemePreference? preference,
    bool? isSaving,
    String? Function()? mutationError,
  }) {
    return ThemePreferencesState(
      preference: preference ?? this.preference,
      isSaving: isSaving ?? this.isSaving,
      mutationError: mutationError != null
          ? mutationError()
          : this.mutationError,
    );
  }

  @override
  List<Object?> get props => [preference, isSaving, mutationError];
}
