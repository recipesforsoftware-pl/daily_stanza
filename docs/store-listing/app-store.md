# Apple App Store Connect — Submission Worksheet

Working document for the **App Store Connect** submission of **Daily Stanza**.
Every factual statement in this file is backed by the repository unless it is
explicitly marked as a recommendation or as a manual confirmation.

> Nothing in this document is an approval. Apple App Review applies its own
> policies and may request changes.

## Identity

| Field | Value | Source |
|---|---|---|
| Application name | Daily Stanza | `ios/Runner/Info.plist` (`CFBundleDisplayName`) |
| Bundle identifier | `pl.recipesforsoftware.dailystanza` | `ios/Runner.xcodeproj/project.pbxproj` (`PRODUCT_BUNDLE_IDENTIFIER`) |
| Version | `1.0.0` | `pubspec.yaml` via `$(FLUTTER_BUILD_NAME)` |
| Build number | `1` | `pubspec.yaml` via `$(FLUTTER_BUILD_NUMBER)` |

The bundle identifier is confirmed in
`ios/Runner.xcodeproj/project.pbxproj`. The version and build number come from
`pubspec.yaml` (`version: 1.0.0+1`), which is referenced by the iOS build
settings through `$(FLUTTER_BUILD_NAME)` and `$(FLUTTER_BUILD_NUMBER)`.

## Subtitle

App Store limit: **30 characters**.

> A daily public-domain poem.

Measured length: **27 characters** (see character-count section).

## Promotional text

App Store limit: **170 characters**.

> One curated public-domain poem every day, in English or Polish. No account
> needed — your favourites and preferences stay on your device.

Measured length: **136 characters** (see character-count section).

## Full description

App Store limit: **4000 characters**.

Draft:

> Daily Stanza brings you one carefully selected public-domain poem every day,
> in English or Polish.
>
> Features
>
> - A new poem each day — a curated daily assignment, prepared in advance from
>   verified public-domain sources.
> - English and Polish — choose your preferred poem language in Settings.
> - Favourites — save the poems you love and revisit them in the Favourites
>   tab. Favourites stay on your device.
> - Comfortable reading — a focused, scrollable reading view for each poem.
> - Light, dark, and system appearance — pick a theme or follow your device.
> - Sharing — share a poem using your device's standard share sheet.
> - Offline awareness — a recently viewed poem can still be displayed when you
>   are offline.
>
> Private by design
>
> - No account, no login, and no password.
> - No payments, subscriptions, or advertising.
> - Your poem language, theme, onboarding progress, and favourites are stored
>   locally on your device.
> - Daily Stanza does not use analytics or crash reporting. It does not ask you
>   to create an account or provide personal information.
>
> Free and open source
>
> Daily Stanza is free to use. The source code is published under the MIT
> License, and each poem retains its original authorship and source
> attribution.
>
> Support
>
> For help, visit the Daily Stanza support page, write to
> recipesforsoftware@gmail.com, or open a GitHub issue.

Measured length: **1300 characters** as entered (the Markdown source block is
1384 characters including blockquote and list markers).

## Keywords

App Store limit: **100 characters**, comma-separated, no spaces.

> poetry,poem,daily,poems,literature,verse,classic,english,polish,reading

Measured length: **71 characters** (see character-count section).

## Links and contact

| Item | Value |
|---|---|
| Privacy Policy URL | https://recipesforsoftware-pl.github.io/daily_stanza/privacy/ |
| Support URL | https://recipesforsoftware-pl.github.io/daily_stanza/support/ |
| Marketing URL | https://recipesforsoftware-pl.github.io/daily_stanza/ |
| Public support email | recipesforsoftware@gmail.com |

All three URLs were fetched and verified reachable during preparation of these
materials.

## Suggested "What's New" text (version 1.0.0)

> Welcome to Daily Stanza! This first release delivers one curated
> public-domain poem every day, with English and Polish options, local
> favourites, light and dark themes, and sharing.

These are suggested notes only. The final "What's New" text is entered manually
in App Store Connect.

## iOS screenshots already present in the repository

Path: `docs/screenshots/ios/`

| Screenshot | Dimensions |
|---|---|
| `01-onboarding.png` | 1170 × 2532 |
| `02-today-en.png` | 1170 × 2532 |
| `03-today-pl.png` | 1170 × 2532 |
| `04-favourites.png` | 1170 × 2532 |
| `05-poem-detail.png` | 1170 × 2532 |
| `06-settings-light.png` | 1170 × 2532 |
| `07-settings-dark.png` | 1170 × 2532 |

The 1170 × 2532 screenshots are the accepted 6.1-inch screenshot size. A
6.9-inch or 6.5-inch screenshot set still needs to be prepared or confirmed for
the primary iPhone screenshot requirement before submission.

## Age-rating observations

Based only on functionality verified in the repository:

- The app displays curated public-domain poetry. No user-generated content is
  shown to other users.
- There is no realistic violence, horror, sexual content or nudity, mature or
  suggestive themes, gambling, drug references, profanity beyond what appears
  in classic literature, unlawful/hateful content, or medical references in
  the application.
- There is no unrestricted web access, no location, no sensitive information
  collection, no in-app purchases, and no explicit content.

The app itself does not add interactive mature-content features. The submitted
poem catalog must still be reviewed when completing the age-rating
questionnaire, because individual poems may contain mature, frightening,
violent, or sensitive themes.

These observations do not constitute an approved rating. The App Store
age-rating questionnaire must be answered manually in App Store Connect.

## App Review information that may be useful

- **No sign-in offered.** App Review does not need to create an account; the
  app requires no login and the "Sign-in required" question in App Review
  information can be answered "No".
- **No demo credentials** exist.
- **Network requirement:** on first launch the app reads the daily poem and its
  assignment from Cloud Firestore. A network connection is needed to load
  content the first time; recently viewed poems can be displayed while offline.
- **First-run experience:** the app shows a short onboarding flow (language and
  appearance) before the Today screen.
- **Contact:** recipesforsoftware@gmail.com and the support URL above are the
  correct channels for review questions.
- **External links:** the Settings screen can open the GitHub repository and
  privacy policy via `url_launcher` (links are defined in
  `lib/core/config/app_links.dart`).

## Manual App Store Connect decisions and confirmations still required

- [ ] Register/confirm the `pl.recipesforsoftware.dailystanza` App ID in the
      developer account and in the `certificates/identifiers/profiles` area.
- [ ] Confirm the app name (max 30 characters; "Daily Stanza" is 12).
- [ ] Upload the build and confirm it is version `1.0.0` build `1`.
- [ ] Enter subtitle, promotional text, keywords, and description (drafts above).
- [ ] Complete the age-rating questionnaire (observations above are not a
      rating).
- [ ] Complete the App Privacy answers (see `privacy-declarations.md`).
- [ ] Answer the Advertising Identifier questions (no ad-ID usage found in the
      repository; final answers are manual).
- [ ] Review Export Compliance information for the build (the app uses standard
      HTTPS/TLS networking through Firebase; final answers are manual).
- [ ] Provide App Review notes, review contact, and (optionally) attach the
      privacy policy URL.
- [ ] Upload screenshots; confirm required device size classes are covered.
- [ ] Confirm pricing and availability (free) and release strategy (App Store /
      TestFlight).
- [ ] Review the "What's New" text before release.
- [ ] Confirm the release uses the version and build intended for store
      distribution.

## Manual confirmations still outstanding

- [ ] Apple privacy manifests included by dependencies and any required-reason
      API declarations.
- [ ] Frameworks and SDKs actually linked into the final release binary.
- [ ] Whether SDK-level diagnostic or technical data processing occurs in the
      released build.
- [ ] Firebase project: enabled services and settings in Firebase Console.
- [ ] Confirm the release archive's bundle identifier and version in the
      uploaded build.
