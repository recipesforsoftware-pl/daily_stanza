import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:daily_stanza/features/onboarding/data/datasource/local_onboarding_data_source.dart';
import 'package:daily_stanza/features/onboarding/data/repository/onboarding_repository_impl.dart';

class MockLocalOnboardingDataSource extends Mock
    implements LocalOnboardingDataSource {}

void main() {
  group('OnboardingRepositoryImpl', () {
    late MockLocalOnboardingDataSource mockDataSource;
    late OnboardingRepositoryImpl repository;

    setUp(() {
      mockDataSource = MockLocalOnboardingDataSource();
      repository = OnboardingRepositoryImpl(dataSource: mockDataSource);
    });

    test('isOnboardingCompleted returns false when key is absent', () async {
      when(() => mockDataSource.getOnboardingCompleted()).thenReturn(null);

      final result = await repository.isOnboardingCompleted();

      expect(result, isFalse);
    });

    test('isOnboardingCompleted returns stored true value', () async {
      when(() => mockDataSource.getOnboardingCompleted()).thenReturn(true);

      final result = await repository.isOnboardingCompleted();

      expect(result, isTrue);
    });

    test('isOnboardingCompleted returns stored false value', () async {
      when(() => mockDataSource.getOnboardingCompleted()).thenReturn(false);

      final result = await repository.isOnboardingCompleted();

      expect(result, isFalse);
    });

    test('setOnboardingCompleted persists the value', () async {
      when(
        () => mockDataSource.setOnboardingCompleted(),
      ).thenAnswer((_) async => true);

      await repository.setOnboardingCompleted();

      verify(() => mockDataSource.setOnboardingCompleted()).called(1);
    });

    test('setOnboardingCompleted throws when persistence fails', () async {
      when(
        () => mockDataSource.setOnboardingCompleted(),
      ).thenAnswer((_) async => false);

      expect(
        () => repository.setOnboardingCompleted(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
