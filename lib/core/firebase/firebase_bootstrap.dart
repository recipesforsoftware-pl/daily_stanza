import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;

import 'package:daily_stanza/core/config/app_environment.dart';
import 'package:daily_stanza/firebase_options.dart';

/// Project ID used by the local Firestore emulator.
///
/// The emulator runs its own namespace independent of any Firebase project.
/// A secondary Firebase app is created with this ID so the Firestore client
/// reads from the correct emulator namespace.
const emulatorProjectId = 'demo-daily-stanza';

/// Name of the secondary Firebase app used exclusively for emulator Firestore.
const _emulatorAppName = 'daily-stanza-emulator';

/// Bootstraps Firebase and returns a configured [FirebaseFirestore] instance.
///
/// Applies all Firestore settings before any read can occur. In emulator mode
/// persistence is disabled to avoid stale local cache between emulator
/// restarts; in production mode persistence is enabled for offline support.
///
/// In emulator mode a secondary Firebase app ([_emulatorAppName]) is created
/// with project ID [emulatorProjectId] so that the Firestore client addresses
/// the correct emulator namespace. The default Firebase app retains the
/// production project ID for all other Firebase services.
///
/// Firebase initialization errors are intentionally propagated so that startup
/// configuration failures remain visible.
class FirebaseBootstrap {
  FirebaseBootstrap._();

  /// Initializes Firebase and configures Firestore according to [environment].
  ///
  /// Production:
  ///   - Initializes the default Firebase app with `DefaultFirebaseOptions`
  ///   - Returns [FirebaseFirestore.instance] with persistence enabled.
  ///
  /// Emulator ([environment.useFirestoreEmulator] is `true`):
  ///   - Initializes the default Firebase app (keeps production project
  ///     available for any other Firebase service).
  ///   - Creates or reuses a secondary named Firebase app with the project ID
  ///     [emulatorProjectId] so the Firestore client addresses the correct
  ///     emulator namespace.
  ///   - Connects that secondary Firestore instance to the emulator host/port.
  ///   - Disables persistence for the emulator instance.
  ///   - Returns the emulator Firestore instance.
  static Future<FirebaseFirestore> initialize(
    AppEnvironment environment,
  ) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    if (environment.useFirestoreEmulator) {
      return _initializeEmulator(environment);
    }

    return _initializeProduction();
  }

  /// Configures the default [FirebaseFirestore.instance] for production.
  static FirebaseFirestore _initializeProduction() {
    final firestore = FirebaseFirestore.instance;
    firestore.settings = const Settings(persistenceEnabled: true);
    return firestore;
  }

  /// Creates or reuses a named secondary Firebase app with the emulator
  /// project ID and returns its Firestore instance connected to the emulator.
  static Future<FirebaseFirestore> _initializeEmulator(
    AppEnvironment environment,
  ) async {
    final options = DefaultFirebaseOptions.currentPlatform.copyWith(
      projectId: emulatorProjectId,
    );

    // Reuse the named app if it already exists (hot restart, repeated
    // initialization in tests). Firebase.initializeApp with a duplicate
    // name would throw.
    final emulatorApp =
        Firebase.apps
            .where((app) => app.name == _emulatorAppName)
            .firstOrNull ??
        await Firebase.initializeApp(name: _emulatorAppName, options: options);

    final firestore = FirebaseFirestore.instanceFor(app: emulatorApp);

    final host = environment.resolveFirestoreEmulatorHost(
      defaultTargetPlatform,
    );
    firestore.useFirestoreEmulator(host, environment.firestoreEmulatorPort);
    firestore.settings = const Settings(persistenceEnabled: false);

    return firestore;
  }
}
