import 'package:flutter_test/flutter_test.dart';

import 'package:daily_stanza/core/firebase/firebase_bootstrap.dart';
import 'package:daily_stanza/firebase_options.dart';

void main() {
  group('FirebaseBootstrap', () {
    group('emulatorProjectId', () {
      test('is demo-daily-stanza', () {
        expect(emulatorProjectId, equals('demo-daily-stanza'));
      });
    });

    group('production project IDs', () {
      test('Android production project ID is daily-stanza-prod-ks', () {
        expect(
          DefaultFirebaseOptions.android.projectId,
          equals('daily-stanza-prod-ks'),
        );
      });

      test('iOS production project ID is daily-stanza-prod-ks', () {
        expect(
          DefaultFirebaseOptions.ios.projectId,
          equals('daily-stanza-prod-ks'),
        );
      });

      test('production project ID is not the emulator project ID', () {
        expect(
          DefaultFirebaseOptions.android.projectId,
          isNot(equals(emulatorProjectId)),
        );
        expect(
          DefaultFirebaseOptions.ios.projectId,
          isNot(equals(emulatorProjectId)),
        );
      });
    });

    group('emulator options derivation', () {
      test('copyWith overrides projectId to emulator project', () {
        final emulatorOptions = DefaultFirebaseOptions.android.copyWith(
          projectId: emulatorProjectId,
        );

        expect(emulatorOptions.projectId, equals(emulatorProjectId));
      });

      test('copyWith preserves other Firebase options unchanged', () {
        final emulatorOptions = DefaultFirebaseOptions.android.copyWith(
          projectId: emulatorProjectId,
        );

        expect(
          emulatorOptions.apiKey,
          equals(DefaultFirebaseOptions.android.apiKey),
        );
        expect(
          emulatorOptions.appId,
          equals(DefaultFirebaseOptions.android.appId),
        );
        expect(
          emulatorOptions.messagingSenderId,
          equals(DefaultFirebaseOptions.android.messagingSenderId),
        );
      });
    });
  });
}
