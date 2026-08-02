import 'package:daily_stanza/features/settings/domain/model/app_info.dart';

/// Application-facing abstraction over platform package-info APIs.
abstract interface class AppInfoService {
  /// Loads the current application package information.
  Future<AppInfo> getAppInfo();
}
