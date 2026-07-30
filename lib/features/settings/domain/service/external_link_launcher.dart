/// Application-facing abstraction over platform URL launching.
abstract interface class ExternalLinkLauncher {
  /// Attempts to open [url] in an external application.
  ///
  /// Returns `true` when the launch request was successfully dispatched,
  /// `false` otherwise.
  Future<bool> launchUrl(Uri url);
}
