# Development — Daily Stanza

## Prerequisites

- **Flutter SDK** — stable channel
- **Dart SDK** — matching the `sdk: ^3.12.2` constraint in `pubspec.yaml`
  (bundled with Flutter)
- **Firebase CLI** — `firebase` command on `$PATH`
- **Node.js 22** — required for Firestore Rules tests (see `.nvmrc`)

## Clone and dependencies

```sh
git clone https://github.com/recipesforsoftware-pl/daily_stanza.git
cd daily_stanza
flutter pub get
```

## Firebase configuration

Firebase client configuration files are local-only and excluded from the
repository via `.gitignore`:

- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

Authorized maintainers restore them from a secure, repository-external
location:

```sh
./tool/setup_firebase_config.sh
```

A reference for the required Firebase project aliases is available in
`.firebaserc.example`.

A fresh clone without these files cannot run `flutter analyze` or build the
production composition root.

## Local Firestore emulator

The emulator workflow uses a separate Firebase project namespace
(`demo-daily-stanza`) independent from production.

**Terminal 1 — Start the emulator:**

```sh
firebase emulators:start --only firestore --project demo-daily-stanza
```

**Terminal 2 — Seed poems for the current date:**

```sh
dart run tool/seed_firestore.dart
```

This seeds the current local calendar date. To seed for a specific date:

```sh
dart run tool/seed_firestore.dart --date 2026-08-03
```

The seed tool is emulator-only: it targets `demo-daily-stanza` on
`localhost:8080`, writes every poem in the catalog, and writes exactly two
daily assignments (one English, one Polish) for the selected date. If the
selected date has no complete English/Polish pair, the tool prints an error
and exits without writing anything.

**Terminal 2 (or 3) — Run the app against the emulator:**

```sh
flutter run --dart-define=USE_FIRESTORE_EMULATOR=true
```

When running on a physical device on the same LAN as the development machine,
override the emulator host with the machine's IP address:

```sh
flutter run \
  --dart-define=USE_FIRESTORE_EMULATOR=true \
  --dart-define=FIRESTORE_EMULATOR_HOST=192.168.1.100
```

To use a non-default emulator port:

```sh
flutter run \
  --dart-define=USE_FIRESTORE_EMULATOR=true \
  --dart-define=FIRESTORE_EMULATOR_PORT=8080
```

The emulator flag is opt-in. Omitting it uses the production Firebase project.

## Production-connected local run

```sh
flutter run
```

This connects to the production Firebase project. Valid local Firebase client
configuration files must be in place.

## Validation

**Formatting check:**

```sh
git ls-files -z '*.dart' | xargs -0 dart format --output=none --set-exit-if-changed
```

**Static analysis:**

```sh
flutter analyze
```

**All Dart tests:**

```sh
flutter test
```

**Focused tests (single file):**

```sh
flutter test test/features/daily_poem/presentation/bloc/daily_poem_bloc_test.dart
```

**Firestore Rules tests (requires Node.js 22 and Java 21):**

```sh
firebase emulators:exec --only firestore --project demo-daily-stanza \
  "cd firebase && node ./node_modules/jest/bin/jest.js --runInBand"
```

This starts the Firestore emulator, runs the Jest-based Rules tests in
`firebase/test/firestore.rules.test.js`, then stops the emulator.

**Catalog validation:**

```sh
dart run tool/validate_catalog.dart
```

Validates poem entries, daily assignments, cross-references, and catalog
invariants. Exits with a non-zero code on error.

**Catalog provenance validation:**

```sh
dart run tool/validate_catalog_provenance.dart
```

## Builds

**Android debug APK:**

```sh
flutter build apk --debug
```

**Android release APK (requires signing configuration):**

```sh
flutter build apk
```

**iOS debug build (requires a Mac with Xcode):**

```sh
flutter build ios --debug --no-codesign
```

## Troubleshooting

**"Could not connect to the Firestore emulator"**

Ensure the emulator is running (`firebase emulators:start ...`) and accessible
on `localhost:8080`.

**"firebase_options.dart not found" or build failure at startup**

Firebase client configuration files are missing. Restore them with
`./tool/setup_firebase_config.sh`.

**Firestore permission-denied errors**

The deployed Security Rules may not match the local `firestore.rules`. Deploy
with `firebase deploy --only firestore:rules --project <project-id>`. In the
emulator, rules are loaded from the local `firestore.rules` file automatically.

**Emulator reads stale data after a restart**

Restart the Flutter app after restarting the emulator. The emulator workflow
disables Firestore persistence to avoid stale cache.

**Confusion between production and emulator mode**

Run `flutter run` (default) for production. Add
`--dart-define=USE_FIRESTORE_EMULATOR=true` for the emulator. Check the
console output at startup to confirm which mode is active.
