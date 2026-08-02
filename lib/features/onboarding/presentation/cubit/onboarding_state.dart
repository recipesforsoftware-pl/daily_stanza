import 'package:equatable/equatable.dart';

enum OnboardingStatus { resolving, resolved }

final class OnboardingState extends Equatable {
  const OnboardingState({
    this.completed = false,
    this.status = OnboardingStatus.resolving,
    this.isCompleting = false,
    this.mutationError,
  });

  final bool completed;
  final OnboardingStatus status;
  final bool isCompleting;

  /// One-time error message from a failed mutation.
  ///
  /// The global listener shows it via SnackBar. The next emission clears it.
  final String? mutationError;

  bool get isResolved => status == OnboardingStatus.resolved;

  OnboardingState copyWith({
    bool? completed,
    OnboardingStatus? status,
    bool? isCompleting,
    String? Function()? mutationError,
  }) {
    return OnboardingState(
      completed: completed ?? this.completed,
      status: status ?? this.status,
      isCompleting: isCompleting ?? this.isCompleting,
      mutationError: mutationError != null
          ? mutationError()
          : this.mutationError,
    );
  }

  @override
  List<Object?> get props => [completed, status, isCompleting, mutationError];
}
