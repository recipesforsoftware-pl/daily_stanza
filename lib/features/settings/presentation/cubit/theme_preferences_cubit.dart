import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_stanza/features/settings/domain/model/theme_preference.dart';
import 'package:daily_stanza/features/settings/domain/repository/theme_preferences_repository.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/theme_preferences_state.dart';

class ThemePreferencesCubit extends Cubit<ThemePreferencesState> {
  ThemePreferencesCubit({
    required ThemePreferencesRepository repository,
    required ThemePreference initialPreference,
  }) : _repository = repository,
       super(ThemePreferencesState(preference: initialPreference));

  final ThemePreferencesRepository _repository;

  static const String _errorMessage =
      'Failed to save theme preference. Please try again.';

  Future<void> changeTheme(ThemePreference newPreference) async {
    if (state.isSaving) return;
    if (state.preference == newPreference) return;

    emit(state.copyWith(isSaving: true, mutationError: () => null));

    try {
      await _repository.setPreferredTheme(newPreference);
      emit(
        ThemePreferencesState(preference: newPreference, mutationError: null),
      );
    } catch (_) {
      emit(
        ThemePreferencesState(
          preference: state.preference,
          mutationError: _errorMessage,
        ),
      );
    }
  }
}
