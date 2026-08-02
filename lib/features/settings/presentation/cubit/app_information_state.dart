import 'package:equatable/equatable.dart';
import 'package:daily_stanza/features/settings/domain/model/app_info.dart';

final class AppInformationState extends Equatable {
  const AppInformationState({this.appInfo, this.isLoading = false, this.error});

  final AppInfo? appInfo;
  final bool isLoading;
  final String? error;

  AppInformationState copyWith({
    AppInfo? appInfo,
    bool? isLoading,
    String? Function()? error,
  }) {
    return AppInformationState(
      appInfo: appInfo ?? this.appInfo,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
    );
  }

  @override
  List<Object?> get props => [appInfo, isLoading, error];
}
