import 'package:daily_stanza/features/onboarding/data/datasource/local_onboarding_data_source.dart';
import 'package:daily_stanza/features/onboarding/domain/repository/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  const OnboardingRepositoryImpl({
    required LocalOnboardingDataSource dataSource,
  }) : _dataSource = dataSource;

  final LocalOnboardingDataSource _dataSource;

  @override
  Future<bool> isOnboardingCompleted() async {
    return _dataSource.getOnboardingCompleted() ?? false;
  }

  @override
  Future<void> setOnboardingCompleted() async {
    final result = await _dataSource.setOnboardingCompleted();
    if (!result) {
      throw Exception('Failed to save onboarding completion');
    }
  }
}
