# Privacy Declarations — Worksheet (Google Play Data Safety & Apple App Privacy)

This worksheet supports the two store privacy questionnaires:

- **Google Play — Data safety**
- **Apple — App Privacy (App Store Connect)**

Every item below is classified with one of three statuses:

| Mark | Meaning |
|---|---|
| **Confirmed** | Directly supported by repository evidence inspected for this task. |
| **Technical conclusion** | A reasonable inference from dependency, platform, or Firebase behaviour; still requires store-form confirmation. |
| **Manual** | Cannot be determined from the repository; must be entered or confirmed in the store console (or verified in the released build / Firebase Console). |

> **Important:** Do not record "no data is collected" as an unconditional,
> final store-form answer in this worksheet. That exact conclusion depends on
> the final released build, dependency behaviour, and the specific wording of
> the store forms. Use the classifications below and complete the manual steps
> listed at the end.

## Repository evidence used

- `pubspec.yaml` / `pubspec.lock` — direct and transitive dependencies.
- `.flutter-plugins-dependencies` — plugins registered for Android and iOS.
- `lib/features/...` — application behaviour (Firestore datasource, local
  storage data sources, share service, app-info service, link launcher).
- `firestore.rules` — read-only client access model.
- `android/app/src/main/AndroidManifest.xml` — no `<uses-permission>` entries.
- `ios/Runner/Info.plist` — no `NS*UsageDescription` keys.
- `PRIVACY_POLICY.md`, `docs/support.md` — published policy/support text.

## Topic-by-topic worksheet

### 1. Accounts and login

- **Confirmed:** no account system, no login, no password, no sign-in UI, and
  no authentication dependencies in the application.
- **Manual:** none of the store forms require anything further for this topic,
  but the App Review "sign-in required" question is answered manually.

### 2. Forms collecting personal information

- **Confirmed:** no forms that collect personal information exist in the
  application. Onboarding collects only language and appearance preferences,
  stored locally.
- **Technical conclusion:** nothing in the repository sends form data anywhere.

### 3. Local SharedPreferences storage

- **Confirmed:** favourites, poem language, theme preference, and onboarding
  completion are stored with `SharedPreferences`
  (`lib/features/favourites/data/datasource/local_favourites_data_source.dart`,
  `lib/features/settings/data/datasource/*.dart`,
  `lib/features/onboarding/data/datasource/local_onboarding_data_source.dart`).
- **Confirmed:** no server-side profile exists; this local data is not
  uploaded by application code.
- **Manual:** the exact persistence backend (SharedPreferences vs plugin
  platform implementation) on the user's device is handled by the
  `shared_preferences` plugin.

### 4. Read-only Firestore content access

- **Confirmed:** the app reads daily assignments and poems from Cloud Firestore
  (`lib/features/daily_poem/data/datasource/firestore_poem_data_source.dart`)
  using only `.get()` reads.
- **Confirmed:** `firestore.rules` permit reads only for approved poems and
  published assignments, and deny client create/update/delete.
- **Technical conclusion:** read requests to Cloud Firestore are network
  requests made on the user's behalf to Google's servers.
- **Manual:** which Firebase services are enabled in the Firebase Console, and
  any Firebase-side settings (for example, usage/diagnostic settings, data
  retention, or Cloud Firestore request logging).

### 5. No client Firestore writes

- **Confirmed:** no `.set()`, `.add()`, `.update()`, or `.delete()` calls to
  Firestore exist in application code. Searches of `lib/` found no Firestore
  write operations.
- **Manual:** confirm no write paths are introduced in the released build and
  that Firebase Console settings do not record app-side writes.

### 6. Native share sheet

- **Confirmed:** sharing uses `share_plus` to open the operating system share
  sheet (`lib/features/share_poem/data/service/share_plus_poem_share_service.dart`).
- **Confirmed:** the app does not see or store what is shared or where.
- **Technical conclusion:** the share target application chosen by the user
  receives the shared text; that is user-initiated, not app data collection.

### 7. Advertising dependency

- **Confirmed:** no advertising SDK (for example AdMob) appears in
  `pubspec.yaml`, `pubspec.lock`, or the generated plugin lists.
- **Manual:** store "Ads" declaration and any ad-related Data safety / App
  Privacy answers.

### 8. Analytics dependency

- **Confirmed:** no analytics SDK (for example Firebase Analytics,
  `firebase_analytics`) appears in the dependency graph.
- **Manual:** confirm the released binary and Firebase Console settings do not
  enable analytics at the SDK or service level.

### 9. Crash-reporting dependency

- **Confirmed:** no crash-reporting SDK (for example Firebase Crashlytics) is
  present in the dependency graph.
- **Manual:** confirm the released binary contains no crash-reporting
  functionality.

### 10. Payment functionality

- **Confirmed:** no payment, billing, subscriptions, or in-app purchase
  functionality or dependencies exist in the application.

### 11. Notifications

- **Confirmed:** no notification functionality or notification permissions are
  used by the application.

### 12. Location, camera, microphone, contacts, photo library

- **Confirmed:** no functionality uses location, camera, microphone, contacts,
  or the photo library.
- **Confirmed:** the Android main manifest declares no `<uses-permission>`
  entries, and `ios/Runner/Info.plist` declares no `NS*UsageDescription` keys.
- **Technical conclusion:** some platform frameworks may declare permissions in
  their own manifests; the final merged Android release manifest and linked iOS
  frameworks must be reviewed (see Manual items).

### 13. What the application itself collects

- **Confirmed:** the application code does not collect, transmit, or store
  personal information, usage analytics, advertising identifiers, or location
  data. Local preferences and favourites never leave the device through
  application code.
- **Confirmed:** the only outbound network activity in application code is the
  read-only Firestore content fetch described above.
- **Technical conclusion:** Firebase SDKs and platform frameworks may process
  technical or device-level data (for example device identifiers, IP addresses,
  or diagnostics) according to their own policies.
- **Manual:** decide and enter the exact Data safety / App Privacy answers
  based on the released build and the current store forms.

## Google Play — Data safety mapping

Play Console asks whether your app collects and shares data, what types, how it
is handled, and whether deletion is possible. Preliminary mapping (final
answers are manual):

| Play Data safety area | Preliminary answer | Status |
|---|---|---|
| Data collected by your app | None from application code | Confirmed (app code) / Manual (final form) |
| Data collected by third-party SDKs | No advertising/analytics/crash SDKs found | Confirmed (dependency graph) / Manual (released binary) |
| Network content requests to Firestore | Read-only public content; no user data uploaded | Confirmed (rules + code) |
| Data shared with third parties | No data shared by the app itself | Confirmed (app code) / Manual (SDK behaviour) |
| Data encrypted in transit | Firestore traffic uses TLS/HTTPS (Firebase SDK) | Technical conclusion |
| User data deletion / "No data collected" answer | No user account or personal data to delete | Confirmed (no accounts) / Manual (final form wording) |
| Ads declaration | No | Confirmed (no ad SDK) / Manual (form) |
| Security practices | Firebase Security Rules restrict reads; writes denied | Confirmed (rules) |

## Apple — App Privacy mapping

| App Privacy item | Preliminary answer | Status |
|---|---|---|
| Data not collected by you | No data collected by the app itself | Confirmed (app code) / Manual (final form) |
| Data collected by SDKs / third parties | No advertising/analytics/crash SDKs found | Confirmed (dependency graph) / Manual (released binary) |
| Tracking / Advertising Identifier | No ad-ID or tracking usage found | Confirmed (no dependencies) / Manual (form) |
| Privacy manifests | No app-level `PrivacyInfo.xcprivacy` found under `ios/Runner` | Confirmed (absence in repository) / Manual (dependency-supplied manifests) |
| Required-reason APIs | No file-timestamp, system boot time, or user-defaults API use found in application code | Confirmed (application code) / Manual (dependency manifests) |
| Export compliance | Standard HTTPS/TLS networking through Firebase | Technical conclusion / Manual (App Store Connect answers) |

## Manual confirmations required (both stores)

- [ ] **Firebase Console** — confirm enabled services, settings, and any
      diagnostic or usage data options for the production project.
- [ ] **Merged Android release manifest** — inspect the final
      `AndroidManifest.xml` produced by the release build (plugin-merged
      permissions and declarations).
- [ ] **Frameworks/SDKs in final release binaries** — list what is actually
      linked into the released Android and iOS binaries.
- [ ] **SDK-level diagnostics** — determine whether any SDK processes
      technical/device data in the released build.
- [ ] **Apple privacy manifests** — confirm which manifests included
      dependencies ship and what they declare.
- [ ] **Required-reason API review** — complete the App Store
      required-reason-API attestation based on linked frameworks.
- [ ] **Final Data safety answers** — enter and submit in Play Console.
- [ ] **Final App Privacy answers** — enter and submit in App Store Connect.
- [ ] **Current store-console forms** — complete any new or changed fields
      required by the current Google Play and App Store Connect forms.

## Boundary statement

This worksheet describes repository-verified behaviour and reasonable technical
conclusions. It is not legal advice and it is not a submitted declaration.
Final store answers are the responsibility of the developer submitting the app.
