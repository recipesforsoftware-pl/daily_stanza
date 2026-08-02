# Google Play Console — Store Submission Worksheet

Working document for the **Google Play** submission of **Daily Stanza**.
Every factual statement in this file is backed by the repository unless it is
explicitly marked as a recommendation or as a manual confirmation.

> Nothing in this document is an approval. Google Play may apply its own
> policies, review processes, and requirements.

## Identity

| Field | Value | Source |
|---|---|---|
| Application name | Daily Stanza | `ios/Runner/Info.plist` / `android/app/src/main/AndroidManifest.xml` (`android:label`) |
| Package name (application ID) | `pl.recipesforsoftware.dailystanza` | `android/app/build.gradle.kts` |
| Version name | `1.0.0` | `pubspec.yaml` (`version: 1.0.0+1`) via `flutter.versionName` |
| Version code | `1` | `pubspec.yaml` (`version: 1.0.0+1`) via `flutter.versionCode` |

The Android package name is confirmed in `android/app/build.gradle.kts`
(`namespace` and `applicationId`). The version name and version code come from
`pubspec.yaml`, which is the single source for `flutter.versionName` and
`flutter.versionCode` referenced in the Gradle configuration.

## Recommended category

**Recommendation only — not applied or approved.**

- **Books & Reference** — recommended for a daily, curated public-domain poem
  reader. This is a suggestion; the final category is chosen manually in Play
  Console and is not confirmed in the repository.

## Short description

Google Play limit: **80 characters**.

> One public-domain poem every day, in English or Polish.

Measured length: **55 characters** (see character-count section).

## Full description

Google Play limit: **4000 characters**.

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

## Links and contact

| Item | Value |
|---|---|
| Privacy policy URL | https://recipesforsoftware-pl.github.io/daily_stanza/privacy/ |
| Support URL | https://recipesforsoftware-pl.github.io/daily_stanza/support/ |
| Website URL | https://recipesforsoftware-pl.github.io/daily_stanza/ |
| Public support email | recipesforsoftware@gmail.com |

All three URLs were fetched and verified reachable during preparation of these
materials.

## Suggested release notes (version 1.0.0)

Draft for the "What's new in this release" field:

> Welcome to Daily Stanza! This first release delivers one curated
> public-domain poem every day, with English and Polish options, local
> favourites, light and dark themes, and sharing.

These are suggested notes only. The final release notes are entered manually in
Play Console.

## Store graphics already present in the repository

| Asset | Path | Dimensions |
|---|---|---|
| Feature graphic | `docs/store-assets/google-play/feature_graphic_1024x500.png` | 1024 × 500 |
| Store icon (512 px) | `docs/store-assets/google-play/play_store_icon_512.png` | 512 × 512 |

Note: these assets exist in the repository at
`docs/store-assets/google-play`. Uploading and validating them against the
current Play Console graphic requirements is a manual step.

## Android screenshots already present in the repository

Path: `docs/screenshots/android/`

| Screenshot | Dimensions |
|---|---|
| `01-onboarding.png` | 1344 × 2992 |
| `02-today-en.png` | 1344 × 2992 |
| `03-today-pl.png` | 1344 × 2992 |
| `04-favourites.png` | 1344 × 2992 |
| `05-poem-detail.png` | 1344 × 2992 |
| `06-settings-light.png` | 1344 × 2992 |
| `07-settings-dark.png` | 1344 × 2992 |

These seven source screenshots are not currently upload-ready under the Google
Play rule that the longer dimension must not exceed twice the shorter
dimension (2992 ÷ 1344 ≈ 2.23).

- [ ] Manual task before upload: crop, resize, or place the screenshots on a
      compliant canvas so the longer dimension does not exceed twice the
      shorter dimension.

## Content-rating observations

Based only on functionality verified in the repository:

- The app displays curated public-domain poetry. No user-generated content is
  shown to other users.
- There is no violence, sexual content, gambling, drugs/alcohol imagery,
  in-app purchases, or location handling in the application.
- Classic poetry may occasionally use older language; the final rating answers
  are the submittor's responsibility in the Play Console questionnaire.

The app itself does not add interactive mature-content features. The submitted
poem catalog must still be reviewed when completing the content-rating
questionnaire, because individual poems may contain mature, frightening,
violent, or sensitive themes.

These observations do not constitute an approved rating. The content-rating
questionnaire must be completed manually in Play Console and is reviewed by
Google.

## App access declaration (observations)

- The app has no account system, no login, and no gated or restricted
  functionality. All features are available without authentication.
- The Play Console "App access" declaration must still be completed manually,
  and Google may ask follow-up questions during review.

## Ads declaration (observations)

- No advertising SDKs or ad-serving functionality were found in the
  application or its dependency graph (verified in `pubspec.yaml`,
  `pubspec.lock`, and the generated plugin lists).
- The Play Console "Ads" declaration still needs to be set manually; based on
  the repository evidence the answer is expected to be "No".

## Target audience (observations)

- The app is written for a general audience; content is curated public-domain
  poetry. The app does not specifically target children.
- If the submittor chooses to include children in the target audience, extra
  Data safety, COPPA, and (potentially) "Designed for Families" requirements
  would apply. This decision is manual and is not decided by the repository.

## Manual inputs required in Play Console

The following cannot be derived from the repository and must be entered or
confirmed by a human in the Play Console:

- [ ] Developer account and developer page (name, contact details).
- [ ] App signing: confirm the upload key / Play App Signing fingerprint and
      the certificate that signs the uploaded App Bundle.
- [ ] Upload of the Android App Bundle artifact (the repository contains a
      release pipeline and a release candidate; no release has been submitted).
- [ ] Category selection (recommendation above: Books & Reference).
- [ ] Content-rating questionnaire answers.
- [ ] Data safety form answers (see `privacy-declarations.md`).
- [ ] Target audience and any country/region availability.
- [ ] "App access" declaration.
- [ ] "Ads" declaration.
- [ ] Store listing artwork uploads (feature graphic, icon, screenshots) and
      compliance with current graphic requirements.
- [ ] Release track configuration (production / closed or open testing).
- [ ] Final short description, full description, and release notes.
- [ ] Final Data safety answers and any Google verification steps.

## Manual confirmations still outstanding

- [ ] Firebase project: enabled services and settings in Firebase Console.
- [ ] Final merged Android release manifest (including plugin-merged
      permissions and declarations).
- [ ] Frameworks and SDKs actually linked into the final release binaries.
- [ ] Whether SDK-level diagnostic or technical data processing occurs in the
      released build.
- [ ] Confirm the release App Bundle artifact version (`1.0.0 (1)`) and package
      name before upload.
