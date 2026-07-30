import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:daily_stanza/features/settings/domain/service/external_link_launcher.dart';

/// [ExternalLinkLauncher] implementation backed by `url_launcher`.
class UrlLauncherExternalLinkLauncher implements ExternalLinkLauncher {
  @override
  Future<bool> launchUrl(Uri url) async {
    return launcher.launchUrl(
      url,
      mode: launcher.LaunchMode.externalApplication,
    );
  }
}
