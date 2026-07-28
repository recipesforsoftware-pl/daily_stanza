# daily_stanza

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

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
