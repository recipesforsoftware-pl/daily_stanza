import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_stanza/features/settings/domain/service/app_info_service.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/app_information_state.dart';

class AppInformationCubit extends Cubit<AppInformationState> {
  AppInformationCubit({required AppInfoService appInfoService})
    : _appInfoService = appInfoService,
      super(const AppInformationState());

  final AppInfoService _appInfoService;

  static const String _errorMessage =
      'Failed to load app information. Please try again.';

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, error: () => null));
    try {
      final appInfo = await _appInfoService.getAppInfo();
      emit(
        AppInformationState(appInfo: appInfo, isLoading: false, error: null),
      );
    } catch (_) {
      emit(
        const AppInformationState(
          appInfo: null,
          isLoading: false,
          error: _errorMessage,
        ),
      );
    }
  }
}
