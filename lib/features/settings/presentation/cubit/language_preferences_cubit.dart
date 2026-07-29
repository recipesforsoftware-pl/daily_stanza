import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_stanza/features/settings/domain/model/poem_language.dart';
import 'package:daily_stanza/features/settings/domain/repository/language_preferences_repository.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/language_preferences_state.dart';

class LanguagePreferencesCubit extends Cubit<LanguagePreferencesState> {
  LanguagePreferencesCubit({
    required LanguagePreferencesRepository repository,
    required PoemLanguage initialLanguage,
  }) : _repository = repository,
       super(LanguagePreferencesState(language: initialLanguage));

  final LanguagePreferencesRepository _repository;

  static const String _errorMessage =
      'Failed to save language preference. Please try again.';

  Future<void> changeLanguage(PoemLanguage newLanguage) async {
    if (state.isSaving) return;
    if (state.language == newLanguage) return;

    emit(state.copyWith(isSaving: true, mutationError: () => null));

    try {
      await _repository.setPreferredLanguage(newLanguage);
      emit(
        LanguagePreferencesState(language: newLanguage, mutationError: null),
      );
    } catch (_) {
      emit(
        LanguagePreferencesState(
          language: state.language,
          mutationError: _errorMessage,
        ),
      );
    }
  }
}
