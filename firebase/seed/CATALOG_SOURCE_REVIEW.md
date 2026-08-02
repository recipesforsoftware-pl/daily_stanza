# Catalog Source Review — catalog_provenance.json

## Overview

This document accompanies `catalog_provenance.json`, the provenance and
rights-status manifest for the 60-poem Daily Stanza production catalog
candidates defined in `catalog_candidates.json`.

**No record in this manifest is a legal determination of public-domain status.**
All records are candidates and remain subject to human source, edition, and
legal review.

## Status Terminology

`catalog_provenance.json` uses only these values:

| Field | Allowed Values | Meaning |
|---|---|---|
| `rightsStatusCandidate` | `public_domain_candidate` | Source appeared reachable, title/author/language matched, edition identified, and no conflicting rights notice was observed. Still **not** a legal approval. |
| `rightsStatusCandidate` | `required_manual_legal_review` | Source could not be fully verified, title/edition/rights notice not confirmed, or network/anti-bot protection prevented inspection. |
| `rightsStatusCandidate` | `rejected` | No usable source was found or the candidate is unsuitable. |
| `reviewStatus` | `pending_human_review` | Awaiting human reviewer. |
| `reviewStatus` | `replacement_candidate_required` | A different candidate should be chosen. |
| `reviewStatus` | `rejected_source` | The proposed source is unsuitable. |

**Forbidden values:** `source_verified`, `public_domain`, `ready_for_production`,
`approved`, or any other final/legal status.

## Classification Summary

| Group | Count | `rightsStatusCandidate` | `reviewStatus` | Automated checks |
|---|---|---|---|---|
| English poems (verified sources) | 27 | `public_domain_candidate` | `pending_human_review` | all true |
| Emily Dickinson | 3 | `required_manual_legal_review` | `pending_human_review` | source/ title/ rights checks false |
| Polish poems | 30 | `required_manual_legal_review` | `pending_human_review` | source/ title/ edition/ text/ rights checks false |

## English-Subset Verification

Source URLs for 27 English-language poems (Blake, Wordsworth, Coleridge,
Shelley, Keats, Poe, Whitman, Rossetti, Hardy) were individually fetched and
confirmed returning HTTP 200. The following URL corrections were applied
compared to earlier skeleton data:

| Skeleton URL | Corrected URL |
|---|---|
| `Ode_to_the_West_Wind_(Shelley)` | `Ode_to_the_West_Wind` |
| `Bright_star,...` | `Last_Sonnet_(Keats)` |
| `To_Helene` | `To_Helen` |
| `This_Lime-Tree_Bower_My_Prison` | `Sibylline_Leaves_(Coleridge)/This_Lime_Tree_Bower_My_Prison` |
| `Poems_(Wordsworth,...)/Composed_upon_Westminster_Bridge` | `Composed_upon_Westminster_Bridge` |

Author death-year Wikipedia pages (Blake, Wordsworth, Coleridge, Shelley,
Keats, Poe, Whitman, Rossetti, Hardy) were confirmed accessible.

## Emily Dickinson

Three Emily Dickinson candidates (`"Hope"`, `Because I could not stop`,
`I heard a Fly buzz`) have candidate URLs on English Wikisource. During the
automated pass these URLs returned HTTP 429 (rate-limiting). They are
therefore classified as `required_manual_legal_review` with the relevant
checks set to `false` until a human reviewer can confirm the exact source
page, edition, and rights notice.

## Polish-Subset Status

Thirty Polish candidates point to either:
- **Wolne Lektury** (`wolnelektury.pl`) — authoritative free-library source
  for Polish literature; or
- **Polish Wikisource** (`pl.wikisource.org`) — used for three Słowacki poems.

These URLs were **not** individually verified in this pass. The site returned
non-200 responses for several URL patterns, possibly due to anti-bot/
Cloudflare protection. All 30 records are classified as
`required_manual_legal_review` with the source/verification checks set to
`false`.

## What Remains for Human Review

1. **Polish source URLs** — manually confirm each Wolne Lektury /
   pl.wikisource.org URL resolves to the correct poem text and edition.
2. **Emily Dickinson URLs** — retry after rate-limiting and confirm exact
   text, edition, and rights notice.
3. **Legal review** — no record is approved; a human reviewer must decide
   whether each candidate may become `public_domain_candidate` or must be
   rejected / replaced.
4. **Edition accuracy** — verify the edition hints in `reviewNotes` against
   the actual source pages.
5. **Rights notices** — confirm no conflicting rights statement exists on each
   source page.
6. **Production import** — only candidates that pass human review and the
   `tool/validate_catalog_provenance.dart` structural checks may later be
   copied to `firebase/seed/poems.json` with `isApproved=true`.

## Life+70 Summary

All 60 authors died more than 70 years before 2026. The most recent death
year is **Julian Tuwim (1953)**, whose Life+70 term expired in 2023.
Therefore every candidate is at least *eligible* for public-domain status
in life-plus-70 jurisdictions. **Life-plus-100 jurisdictions (e.g., Mexico)
may still require separate review.**

## Validation

Run:

```bash
dart run tool/validate_catalog_provenance.dart
```

Expected output is `Validation PASSED` with the structural summary.

Any record that uses `source_verified`, `public_domain`, or `approved`
will cause validation to fail.
