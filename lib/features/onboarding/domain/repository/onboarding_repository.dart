abstract interface class OnboardingRepository {
  /// Returns whether onboarding has been completed.
  ///
  /// A missing value is interpreted as `false`.
  Future<bool> isOnboardingCompleted();

  /// Persists that onboarding has been completed.
  Future<void> setOnboardingCompleted();
}
