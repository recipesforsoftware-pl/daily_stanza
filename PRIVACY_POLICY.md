# Privacy Policy for Daily Stanza

**Effective date:** 30 July 2026

This policy describes how the Daily Stanza mobile and web application handles information. It applies to the version of the app distributed from the public GitHub repository at `https://github.com/recipesforsoftware-pl/daily_stanza`.

## What Daily Stanza is

Daily Stanza is a free Flutter application that displays one curated public-domain poem per day in English or Polish. It does **not** require a user account, login, password, or payment.

## Information stored on your device

The following preferences and identifiers are stored locally on your device using `SharedPreferences`. They are not uploaded to us:

- Your chosen poem language (English or Polish).
- Your appearance/theme preference (System, Light, or Dark).
- Whether you have completed the first-launch onboarding flow.
- The list of poem IDs you have marked as favourites.

You can clear this local data at any time through your device or browser settings.

## Poem content and daily assignments

Poem text, poem metadata, and daily poem assignments are read from **Firebase Cloud Firestore**. The app only reads documents that are marked as approved/published. The Firestore Security Rules do **not** allow public create, update, or delete access from the Flutter client.

## Sharing

When you share a poem, the app formats the poem text and passes it to the operating system’s native share sheet. You choose the destination application. Daily Stanza does not see or store what you share or where you share it.

## Third-party services and SDKs

Daily Stanza is built with Flutter and uses the following third-party packages/services:

- **Firebase SDKs** (Firebase Core, Cloud Firestore) — used to read approved poem data and daily assignments.
- **share_plus** — used to invoke the native share sheet.
- **package_info_plus** — used to read the application name, version, and build number for display on the Settings screen.
- **url_launcher** — used to open external links (GitHub repository, this privacy policy) in your default browser.

These SDKs may process technical or device-level data (for example, device identifiers, IP addresses, or crash diagnostics) according to their own privacy policies. Daily Stanza itself does not collect, transmit, or store personal information, usage analytics, advertising identifiers, or location data.

## No advertising, analytics, authentication, or payments

Daily Stanza does not include advertising, analytics, user authentication, or in-app purchases.

## Your choices

- Change language and theme preferences in **Settings**.
- Remove individual favourites on the **Favourites** screen.
- Clear all app data through your device/browser settings.

## Contact

For questions, suggestions, or data concerns, please open an issue in the GitHub repository:

https://github.com/recipesforsoftware-pl/daily_stanza/issues

## Changes to this policy

We may update this policy when the app changes. The effective date at the top of this document reflects the latest revision.

## Important note

This document describes the app’s current behaviour and is provided for transparency. It is **not legal advice**.
