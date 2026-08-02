import 'package:package_info_plus/package_info_plus.dart';
import 'package:daily_stanza/features/settings/domain/model/app_info.dart';
import 'package:daily_stanza/features/settings/domain/service/app_info_service.dart';

/// [AppInfoService] implementation backed by `package_info_plus`.
class PackageInfoAppInfoService implements AppInfoService {
  @override
  Future<AppInfo> getAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    return AppInfo(
      appName: info.appName,
      version: info.version,
      buildNumber: info.buildNumber,
    );
  }
}
