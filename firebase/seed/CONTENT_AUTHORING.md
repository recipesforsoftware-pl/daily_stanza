# Content Authoring Guide — Daily Stanza Poem Catalog

## Human-Verification Requirements

Every poem added to the production catalog requires human verification of:

- **author identity** — confirmed full name
- **author death year** — for jurisdictions with life-plus terms
- **original publication/source** — first publication details
- **jurisdictional public-domain status** — confirmed free of copyright in the relevant jurisdiction
- **exact source URL** — link to the authoritative edition used
- **exact text edition used** — edition verified, including any modernisation
- **language** — poem language (en or pl)
- **country** — ISO 3166-1 alpha-2 country code
- **rightsStatus** — set to `public_domain`
- **isApproved** — set to `true` only after human review

## Important Caveats

- **AI output is not legal verification.** Automated copyright analysis does not replace human legal judgment.
- **Automatic translation is not part of the MVP.** All catalog content must be original-language text.
- **Modern translations may still be copyrighted.** A public-domain original does not automatically make a modern translation public domain.
- **Translator death/year jurisdiction applies.** Even if the original poem is public domain, a translation may have its own copyright term.
- **sourceUrl should point to the actual text or authoritative source**, not only a generic website homepage.
- **Uncertain records must remain outside the production catalog.** When in doubt, do not include.

## JSON Fields (poems.json)

| Field | Required | Description |
|-------|----------|-------------|
| `id` | yes | Unique poem identifier (lowercase_with_underscores) |
| `title` | yes | Poem title |
| `author` | yes | Author full name |
| `languageCode` | yes | `en` or `pl` |
| `countryCode` | yes | Two-letter uppercase ISO 3166-1 code |
| `content` | yes | Full poem text with preserved line breaks |
| `sourceName` | yes | Publication name and year |
| `sourceUrl` | if available | HTTPS link to authoritative text |
| `rightsStatus` | yes | Must be `public_domain` |
| `isApproved` | yes | `true` only after human review |

## JSON Fields (daily_poems.json)

| Field | Required | Description |
|-------|----------|-------------|
| `id` | yes | `{languageCode}_{yyyyMMdd}` |
| `date` | yes | `yyyy-MM-dd` |
| `languageCode` | yes | `en` or `pl` |
| `poemId` | yes | Must reference a valid poem ID |
| `isPublished` | yes | `true` |

## Validation

Run the catalog validator before any seed operation:

```sh
dart run tool/validate_catalog.dart
```

The validator checks poems, assignments, cross-references, and catalog-level
invariants. It exits with a non-zero code on any error.

## Adding Poems

1. Add entry to `firebase/seed/poems.json`
2. Add corresponding daily assignments to `firebase/seed/daily_poems.json`
3. Run `dart run tool/validate_catalog.dart` to verify
4. Seed the emulator: `dart run tool/seed_firestore.dart`
5. Verify in the Flutter app via the emulator
