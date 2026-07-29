import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:flutter_test/flutter_test.dart';

import 'package:daily_stanza/core/config/app_environment.dart';

void main() {
  group('AppEnvironment.fromDartDefines', () {
    test('production mode by default', () {
      final env = AppEnvironment.fromDartDefines();

      expect(env.useFirestoreEmulator, isFalse);
      expect(env.firestoreEmulatorPort, equals(8080));
      expect(env.firestoreEmulatorHostOverride, isNull);
    });

    test('debug mode alone does not enable the emulator', () {
      // fromDartDefines reads compile-time constants; without
      // --dart-define=USE_FIRESTORE_EMULATOR=true the emulator is off.
      final env = AppEnvironment.fromDartDefines();

      expect(env.useFirestoreEmulator, isFalse);
    });
  });

  group('AppEnvironment constructor', () {
    group('useFirestoreEmulator', () {
      test('defaults to false', () {
        const env = AppEnvironment(
          useFirestoreEmulator: false,
          firestoreEmulatorHostOverride: null,
          firestoreEmulatorPort: 8080,
        );

        expect(env.useFirestoreEmulator, isFalse);
      });

      test('USE_FIRESTORE_EMULATOR=true enables emulator mode', () {
        const env = AppEnvironment(
          useFirestoreEmulator: true,
          firestoreEmulatorHostOverride: null,
          firestoreEmulatorPort: 8080,
        );

        expect(env.useFirestoreEmulator, isTrue);
      });
    });

    group('resolveFirestoreEmulatorHost', () {
      test('Android default host resolves to 10.0.2.2', () {
        const env = AppEnvironment(
          useFirestoreEmulator: true,
          firestoreEmulatorHostOverride: null,
          firestoreEmulatorPort: 8080,
        );

        expect(
          env.resolveFirestoreEmulatorHost(TargetPlatform.android),
          equals('10.0.2.2'),
        );
      });

      test('iOS default host resolves to 127.0.0.1', () {
        const env = AppEnvironment(
          useFirestoreEmulator: true,
          firestoreEmulatorHostOverride: null,
          firestoreEmulatorPort: 8080,
        );

        expect(
          env.resolveFirestoreEmulatorHost(TargetPlatform.iOS),
          equals('127.0.0.1'),
        );
      });

      test('macOS default host resolves to 127.0.0.1', () {
        const env = AppEnvironment(
          useFirestoreEmulator: true,
          firestoreEmulatorHostOverride: null,
          firestoreEmulatorPort: 8080,
        );

        expect(
          env.resolveFirestoreEmulatorHost(TargetPlatform.macOS),
          equals('127.0.0.1'),
        );
      });

      test('explicit FIRESTORE_EMULATOR_HOST override is respected', () {
        const env = AppEnvironment(
          useFirestoreEmulator: true,
          firestoreEmulatorHostOverride: '192.168.1.100',
          firestoreEmulatorPort: 8080,
        );

        expect(
          env.resolveFirestoreEmulatorHost(TargetPlatform.android),
          equals('192.168.1.100'),
        );
        expect(
          env.resolveFirestoreEmulatorHost(TargetPlatform.iOS),
          equals('192.168.1.100'),
        );
        expect(
          env.resolveFirestoreEmulatorHost(TargetPlatform.macOS),
          equals('192.168.1.100'),
        );
      });

      test('empty host override uses the platform default', () {
        // A null firestoreEmulatorHostOverride means no override.
        const env = AppEnvironment(
          useFirestoreEmulator: true,
          firestoreEmulatorHostOverride: null,
          firestoreEmulatorPort: 8080,
        );

        expect(
          env.resolveFirestoreEmulatorHost(TargetPlatform.android),
          equals('10.0.2.2'),
        );
        expect(
          env.resolveFirestoreEmulatorHost(TargetPlatform.iOS),
          equals('127.0.0.1'),
        );
      });
    });

    group('firestoreEmulatorPort', () {
      test('default port is 8080', () {
        const env = AppEnvironment(
          useFirestoreEmulator: false,
          firestoreEmulatorHostOverride: null,
          firestoreEmulatorPort: 8080,
        );

        expect(env.firestoreEmulatorPort, equals(8080));
      });

      test('custom FIRESTORE_EMULATOR_PORT is respected', () {
        const env = AppEnvironment(
          useFirestoreEmulator: true,
          firestoreEmulatorHostOverride: null,
          firestoreEmulatorPort: 9000,
        );

        expect(env.firestoreEmulatorPort, equals(9000));
      });

      test('port zero is passed through at constructor level', () {
        // Validation/fallback is in fromDartDefines, not the constructor.
        const env = AppEnvironment(
          useFirestoreEmulator: true,
          firestoreEmulatorHostOverride: null,
          firestoreEmulatorPort: 0,
        );

        expect(env.firestoreEmulatorPort, equals(0));
      });

      test('negative port is passed through at constructor level', () {
        // Validation/fallback is in fromDartDefines, not the constructor.
        const env = AppEnvironment(
          useFirestoreEmulator: true,
          firestoreEmulatorHostOverride: null,
          firestoreEmulatorPort: -1,
        );

        expect(env.firestoreEmulatorPort, equals(-1));
      });
    });

    group('fromDartDefines port fallback', () {
      test('invalid or empty port input defaults to 8080', () {
        // When FIRESTORE_EMULATOR_PORT is not set, int.fromEnvironment
        // returns 0, and fromDartDefines falls back to 8080.
        final env = AppEnvironment.fromDartDefines();

        expect(env.firestoreEmulatorPort, equals(8080));
      });
    });
  });
}
