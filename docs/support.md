# Daily Stanza — Support

Daily Stanza is a free, open-source Flutter application that displays one
curated public-domain poem every day. It is available on Android and iOS.

This page explains how Daily Stanza works and how to get help. For details on
how your data is handled, see the [Privacy Policy](../PRIVACY_POLICY.md).

## Poem languages

Daily Stanza offers poems in two languages:

- **English**
- **Polish** (Polski)

You can choose the poem language in **Settings** under *Poem language*. The
choice is saved on your device and applies to the daily poem.

## Accounts and login

Daily Stanza does not require an account. There is no login, no password, no
subscription, and no payment of any kind. All features are available without
registering.

## Favourites and preferences

Favourites and preferences are stored **locally on your device** using the
device's app storage (Flutter `SharedPreferences`):

- the list of poems you have marked as favourites;
- your preferred poem language (English or Polish);
- your appearance/theme preference (System, Light, or Dark);
- whether you have completed the first-launch onboarding flow.

None of this data is uploaded to us. Daily Stanza has no account system and no
server-side profile, so your favourites and preferences stay on the device
where they were created.

## Offline behaviour

Daily Stanza caches poem content and daily assignments on your device, so a
recently viewed poem can still be displayed without a network connection. When
the app shows a previously downloaded poem while you are offline, it displays a
banner reading: *"You're offline. Showing a previously downloaded poem."*

If the day's poem has not been cached and there is no connection, the app
shows an error state. You can retry once the connection is restored.

## Sharing poems

When you share a poem, Daily Stanza formats the poem text (title, author, poem
body, and a "Shared from Daily Stanza" attribution) and opens your **operating
system's share sheet**. You choose the destination application. Daily Stanza
does not see or store what you share or where you share it.

## Removing a favourite

- On the **Today** screen, tap the heart icon on a poem you have favourited to
  remove it from your favourites.
- On the **Favourites** screen, use the remove button on a poem card to delete
  that favourite.

Removing a favourite only updates the local list on your device.

## Clearing all app data

Because all app data is stored locally, you can erase it at any time using
your operating system's app settings, or by uninstalling the app:

- **Android** — *Settings → Apps → Daily Stanza → Storage → Clear data* (or
  "Clear storage"), or uninstall the app.
- **iOS** — *Settings → General → iPhone Storage → Daily Stanza → Delete App*,
  or delete the app from the Home Screen.

Uninstalling the app removes all locally stored favourites and preferences.
Clearing this data is permanent and cannot be undone.

## Privacy

For details on what information Daily Stanza stores and why, see the
[Privacy Policy](../PRIVACY_POLICY.md).

## Getting help and reporting bugs

Daily Stanza uses **GitHub Issues** as its public support channel. If you
encounter a problem or have a question, please open an issue:

<https://github.com/recipesforsoftware-pl/daily_stanza/issues>

### What to include in a bug report

To help diagnose the issue quickly, include:

- **App version** — shown in *Settings → App information* (for example,
  `Version 1.0.0 (1)`).
- **Platform** — Android or iOS.
- **OS version** — for example, Android 14 or iOS 17.
- **Steps to reproduce** — what you did, in order.
- **Expected result** — what you expected to happen.
- **Actual result** — what actually happened.
- **Screenshots (optional)** — images or a screen recording showing the
  problem.

### A note on confidentiality

GitHub Issues are **public**. Do not publish passwords, API keys, tokens,
personal data, or any other confidential information in an issue. If an issue
touches on sensitive information, describe the problem without including the
sensitive details.

## Poem sources and provenance

Every poem in Daily Stanza is selected from verified public-domain sources,
including English and Polish Wikisource and Wolne Lektury. Source URLs,
authorship, and rights status are recorded for each poem in the repository,
and new content is reviewed manually before it is added to the catalog. See
[`../firebase/seed/CONTENT_SOURCES.md`](../firebase/seed/CONTENT_SOURCES.md) in
the repository for the full source list.
