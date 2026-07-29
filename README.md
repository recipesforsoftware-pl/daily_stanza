# Daily Stanza

> One poem. One quiet moment. Every day.

Daily Stanza is a portfolio-focused Flutter application that presents
one curated public-domain poem each day.

The project demonstrates production-oriented Flutter development using
BLoC, Firebase Firestore, offline persistence, automated testing and
GitHub Actions.

## Current status

🚧 Active development

The current version includes:

- daily poem delivery from Firestore
- loading, missing, cached and failure states
- offline Firestore persistence
- local English and Polish daily-poem preference
- System/Light/Dark appearance preference
- language and appearance selection persisted on-device with SharedPreferences
- appearance follows the device setting when System is selected
- functional Settings screen with language and appearance sections
- retry handling
- responsive Flutter UI
- local favourites persisted with SharedPreferences
- poem details / focused reading view with scrollable content
- favourites mutation error presented as single SnackBar via global listener
- route-level error boundaries and failure states
- full GoRouter integration with shell navigation
- poem sharing via native share sheet (share_plus 13.3.0)
- share button on Today view (with label) and Poem Details AppBar (icon-only)
- share text: `{title}\nby {author}\n\n{content}\n\nShared from Daily Stanza`
- share subject: `{title} by {author}`
- result mapping: success→completed, dismissed→dismissed, unavailable→unavailable (no error)
- sharing does not reload poems, alter navigation, favourites, language, or theme
- production Firebase project: `daily-stanza-prod-ks`
- Android application ID: `pl.recipesforsoftware.dailystanza`
- iOS bundle identifier: `pl.recipesforsoftware.dailystanza`
- explicit environment-driven Firestore emulator workflow
- 415 automated tests (unit + widget)
- Firestore Security Rules tests (6 rules tests)
- GitHub Actions CI

## Architecture

```
presentation (BLoC / Cubit)
  → repositories (abstract interface)
    → Firestore / SharedPreferences
```

Presentation layers depend on abstract repository interfaces only —
Firestore and SharedPreferences are injected at the composition root.

Favourites are local-only and persisted as poem ID lists through
SharedPreferences.

## Production backend

The default build command connects to the production Firebase project:

```sh
flutter run
```

- Firebase project ID: `daily-stanza-prod-ks`
- Android application ID: `pl.recipesforsoftware.dailystanza`
- iOS bundle identifier: `pl.recipesforsoftware.dailystanza`

Firebase client configuration
(`lib/firebase_options.dart`, `android/app/google-services.json`,
`ios/Runner/GoogleService-Info.plist`) is intentionally excluded from this
public repository — see [Local Firebase client configuration](#local-firebase-client-configuration).

Service-account credentials, private keys, Firebase login tokens, App Check
debug tokens and signing credentials must never be committed.

## Local Firestore Emulator

1. Select Node 22:
   ```sh
   nvm use
   ```

2. Install Firebase test dependencies (first time or after updating `firebase/package.json`):
   ```sh
   cd firebase && npm install && cd ..
   ```

3. Start the Firestore emulator (in a dedicated terminal):
   ```sh
   firebase emulators:start \
     --only firestore \
     --project demo-daily-stanza
   ```

4. Seed poems for the current date (in a second terminal):
   ```sh
   dart run tool/seed_firestore.dart
   ```
   To seed for a specific date:
   ```sh
   dart run tool/seed_firestore.dart --date 2026-07-28
   ```

5. Run the Flutter application against the emulator:
   ```sh
   flutter run \
     --dart-define=USE_FIRESTORE_EMULATOR=true
   ```

The emulator workflow is opt-in. A normal debug build without Dart defines
uses production Firebase.

### Physical Android or iOS device

When running on a physical device that is on the same LAN as the development
Mac, override the emulator host with the Mac's IP address:

```sh
flutter run \
  --dart-define=USE_FIRESTORE_EMULATOR=true \
  --dart-define=FIRESTORE_EMULATOR_HOST=192.168.1.100
```

The device and the development Mac must be on the same network.

### Optional emulator port

The default Firestore emulator port is `8080`. To override it:

```sh
flutter run \
  --dart-define=USE_FIRESTORE_EMULATOR=true \
  --dart-define=FIRESTORE_EMULATOR_PORT=8080
```

## Deployment

Firestore Rules and indexes can be deployed with:

```sh
firebase deploy \
  --only firestore:rules,firestore:indexes \
  --project=daily-stanza-prod-ks
```

Production data seeding is outside the scope of this repository and must be
performed manually through the Firebase Console or a separate, authenticated
admin process.

Do not deploy from CI or commit administrative credentials.

## Local Firebase client configuration

Firebase client configuration is intentionally excluded from this public
repository.

Authorized maintainers store the required files outside the repository in:

```sh
~/.config/daily_stanza/firebase/
```

Required filenames:

- `firebase_options.dart`
- `google-services.json`
- `GoogleService-Info.plist`

Restore them after a fresh clone with:

```sh
./tool/setup_firebase_config.sh
```

CI restores the same files from encrypted GitHub Actions Secrets.

Never commit:

- Firebase client configuration
- service-account credentials
- private keys
- Firebase CLI tokens
- App Check debug tokens
- signing credentials

A fresh clone cannot `flutter analyze` or build the production composition
root until local Firebase configuration is restored.
