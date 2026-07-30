import 'package:equatable/equatable.dart';

/// Application package information surfaced to the UI.
final class AppInfo extends Equatable {
  const AppInfo({
    required this.appName,
    required this.version,
    required this.buildNumber,
  });

  final String appName;
  final String version;
  final String buildNumber;

  @override
  List<Object?> get props => [appName, version, buildNumber];
}
