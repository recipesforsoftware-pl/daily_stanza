import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:daily_stanza/features/settings/domain/model/app_info.dart';
import 'package:daily_stanza/features/settings/domain/service/app_info_service.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/app_information_cubit.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/app_information_state.dart';

class MockAppInfoService extends Mock implements AppInfoService {}

void main() {
  late MockAppInfoService mockAppInfoService;

  setUp(() {
    mockAppInfoService = MockAppInfoService();
  });

  group('AppInformationCubit', () {
    blocTest<AppInformationCubit, AppInformationState>(
      'initial state is empty and not loading',
      build: () => AppInformationCubit(appInfoService: mockAppInfoService),
      expect: () => <AppInformationState>[],
      verify: (cubit) {
        expect(cubit.state.appInfo, isNull);
        expect(cubit.state.isLoading, isFalse);
        expect(cubit.state.error, isNull);
      },
    );

    blocTest<AppInformationCubit, AppInformationState>(
      'emits loading then app info on successful load',
      setUp: () {
        when(() => mockAppInfoService.getAppInfo()).thenAnswer(
          (_) async => const AppInfo(
            appName: 'Daily Stanza',
            version: '1.0.0',
            buildNumber: '1',
          ),
        );
      },
      build: () => AppInformationCubit(appInfoService: mockAppInfoService),
      act: (cubit) => cubit.load(),
      expect: () => [
        const AppInformationState(isLoading: true),
        const AppInformationState(
          appInfo: AppInfo(
            appName: 'Daily Stanza',
            version: '1.0.0',
            buildNumber: '1',
          ),
        ),
      ],
    );

    blocTest<AppInformationCubit, AppInformationState>(
      'emits loading then error on failure',
      setUp: () {
        when(
          () => mockAppInfoService.getAppInfo(),
        ).thenThrow(Exception('package info unavailable'));
      },
      build: () => AppInformationCubit(appInfoService: mockAppInfoService),
      act: (cubit) => cubit.load(),
      expect: () => [
        const AppInformationState(isLoading: true),
        const AppInformationState(
          error: 'Failed to load app information. Please try again.',
        ),
      ],
    );
  });
}
