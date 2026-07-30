import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daily_stanza/features/onboarding/data/datasource/local_onboarding_data_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalOnboardingDataSource', () {
    late SharedPreferences prefs;
    late LocalOnboardingDataSource dataSource;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      dataSource = LocalOnboardingDataSource(sharedPreferences: prefs);
    });

    test('returns null when the key is absent', () {
      expect(dataSource.getOnboardingCompleted(), isNull);
    });

    test('returns true after completion is saved', () async {
      await dataSource.setOnboardingCompleted();
      expect(dataSource.getOnboardingCompleted(), isTrue);
    });

    test('setOnboardingCompleted persists true across recreations', () async {
      await dataSource.setOnboardingCompleted();

      final newPrefs = await SharedPreferences.getInstance();
      final newDataSource = LocalOnboardingDataSource(
        sharedPreferences: newPrefs,
      );

      expect(newDataSource.getOnboardingCompleted(), isTrue);
    });
  });
}
