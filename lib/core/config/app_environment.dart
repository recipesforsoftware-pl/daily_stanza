import 'package:flutter/foundation.dart' show TargetPlatform;

/// Immutable application environment parsed from Dart defines.
///
/// Keeps Firebase and Firestore configuration explicit and testable as pure
/// Dart logic, independent from Firebase static APIs.
class AppEnvironment {
  const AppEnvironment({
    required this.useFirestoreEmulator,
    required this.firestoreEmulatorHostOverride,
    required this.firestoreEmulatorPort,
  });

  /// Parses the environment from `--dart-define` values supplied at build time.
  ///
  /// Supported defines:
  /// - `USE_FIRESTORE_EMULATOR` (`true`/`false`, defaults to `false`)
  /// - `FIRESTORE_EMULATOR_HOST` (overrides the platform default host)
  /// - `FIRESTORE_EMULATOR_PORT` (defaults to `8080`)
  ///
  /// An empty [firestoreEmulatorHostOverride] means the platform default host
  /// should be used.
  factory AppEnvironment.fromDartDefines() {
    const useFirestoreEmulator = bool.fromEnvironment(
      'USE_FIRESTORE_EMULATOR',
      defaultValue: false,
    );
    const hostOverride = String.fromEnvironment('FIRESTORE_EMULATOR_HOST');
    const rawPort = int.fromEnvironment('FIRESTORE_EMULATOR_PORT');

    return AppEnvironment(
      useFirestoreEmulator: useFirestoreEmulator,
      firestoreEmulatorHostOverride: hostOverride.isEmpty ? null : hostOverride,
      firestoreEmulatorPort: rawPort > 0 ? rawPort : _defaultEmulatorPort,
    );
  }

  static const _defaultEmulatorPort = 8080;
  static const _androidEmulatorHost = '10.0.2.2';
  static const _iosSimulatorHost = '127.0.0.1';
  static const _macosSimulatorHost = '127.0.0.1';

  /// Whether the application should connect to a local Firestore emulator.
  final bool useFirestoreEmulator;

  /// Explicit host override for the Firestore emulator.
  ///
  /// When `null`, the platform default is used.
  final String? firestoreEmulatorHostOverride;

  /// Port for the Firestore emulator.
  final int firestoreEmulatorPort;

  /// Resolves the Firestore emulator host for the given platform.
  ///
  /// Uses [firestoreEmulatorHostOverride] when provided, otherwise falls back
  /// to the platform default:
  /// - Android emulator: `10.0.2.2`
  /// - iOS / macOS simulator: `127.0.0.1`
  String resolveFirestoreEmulatorHost(TargetPlatform platform) {
    if (firestoreEmulatorHostOverride != null) {
      return firestoreEmulatorHostOverride!;
    }

    return switch (platform) {
      TargetPlatform.android => _androidEmulatorHost,
      TargetPlatform.iOS => _iosSimulatorHost,
      TargetPlatform.macOS => _macosSimulatorHost,
      _ => _iosSimulatorHost,
    };
  }
}
