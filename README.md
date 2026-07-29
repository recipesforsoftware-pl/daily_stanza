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
- 311 automated tests (unit + widget)
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

## Local development

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
   firebase emulators:start --only firestore --project demo-daily-stanza
   ```

4. Seed poems for the current date (in a second terminal):
   ```sh
   dart run tool/seed_firestore.dart
   ```
   To seed for a specific date:
   ```sh
   dart run tool/seed_firestore.dart --date 2026-07-28
   ```

5. Run the Flutter application:
   ```sh
   flutter run
   ```
