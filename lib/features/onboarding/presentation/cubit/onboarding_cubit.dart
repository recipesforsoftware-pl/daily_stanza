import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_stanza/features/onboarding/domain/repository/onboarding_repository.dart';
import 'package:daily_stanza/features/onboarding/presentation/cubit/onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit({
    required OnboardingRepository repository,
  }) : _repository = repository,
       super(const OnboardingState()) {
    _resolve();
  }

  final OnboardingRepository _repository;

  static const String _errorMessage =
      'Failed to save onboarding progress. Please try again.';

  Future<void> _resolve() async {
    try {
      final completed = await _repository.isOnboardingCompleted();
      // Preserve any in-flight completion state from the UI.
      emit(
        OnboardingState(
          completed: completed,
          status: OnboardingStatus.resolved,
          isCompleting: state.isCompleting,
          mutationError: state.mutationError,
        ),
      );
    } catch (_) {
      // Treat a read failure as incomplete so the user can retry onboarding.
      emit(
        OnboardingState(
          completed: false,
          status: OnboardingStatus.resolved,
          isCompleting: state.isCompleting,
          mutationError: state.mutationError,
        ),
      );
    }
  }

  Future<void> completeOnboarding() async {
    if (state.completed ||
        state.isCompleting ||
        state.status == OnboardingStatus.resolving) {
      return;
    }

    emit(state.copyWith(isCompleting: true, mutationError: () => null));

    try {
      await _repository.setOnboardingCompleted();
      emit(
        const OnboardingState(
          completed: true,
          status: OnboardingStatus.resolved,
          isCompleting: false,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isCompleting: false,
          mutationError: () => _errorMessage,
        ),
      );
    }
  }
}
