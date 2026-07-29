#!/usr/bin/env bash
# shellcheck disable=SC2016
#
# Verify that no Firebase client configuration or privileged credentials are
# tracked in Git.
#
# This script inspects only tracked files.  Ignored local Firebase
# configuration is intentionally skipped.
#
# Usage: ./tool/check_no_tracked_secrets.sh

set -euo pipefail

STATUS=0

# ---------------------------------------------------------------------------
# 1. Forbidden paths — these must never be tracked
# ---------------------------------------------------------------------------
FORBIDDEN_PATHS=(
  lib/firebase_options.dart
  android/app/google-services.json
  ios/Runner/GoogleService-Info.plist
)

for path in "${FORBIDDEN_PATHS[@]}"; do
  if git ls-files --error-unmatch "$path" &>/dev/null 2>&1; then
    echo "ERROR: Firebase client config is tracked: $path" >&2
    STATUS=1
  fi
done

# ---------------------------------------------------------------------------
# 2. Forbidden path patterns — detect by tracked filename, not by content
# ---------------------------------------------------------------------------
while IFS= read -r file; do
  echo "ERROR: Service-account credential file is tracked: $file" >&2
  STATUS=1
done < <(git ls-files | grep -E 'service-account.*\.json$|firebase-adminsdk.*\.json$' || true)

# ---------------------------------------------------------------------------
# 3. High-confidence credential value patterns — scan tracked file content
# ---------------------------------------------------------------------------
# Only patterns that almost certainly represent a real credential value,
# not field names, environment variables, or documentation terms.

# Files that are allowed to mention credential-related patterns without
# containing a real value — for example .gitignore path exclusion rules.
ALLOWLIST_PATTERNS=(
  '\.gitignore$'
)

PATTERNS=(
  # Google API key (AIza...)
  'AIza[0-9A-Za-z_-]{35}'
  # Private key (PKCS#8 PEM header) — POSIX character class for spaces
  'BEGIN[[:space:]]+PRIVATE[[:space:]]+KEY'
  # Service-account client_email JSON field with email value
  '"client_email"[[:space:]]*:[[:space:]]*"[^"@]+@'
  # GitHub personal access token (ghp_ / gho_ / ghu_ / ghs_ / ghr_)
  'gh[pousr]_[A-Za-z0-9_]{25,}'
  # RevenueCat secret API key pattern
  'sk_[A-Za-z0-9]{40,}'
)

while IFS= read -r file; do
  [ -f "$file" ] || continue

  # Skip allowlisted files (e.g. .gitignore with legitimate exclusion rules)
  skip=0
  for allow_pat in "${ALLOWLIST_PATTERNS[@]}"; do
    if [[ "$file" =~ $allow_pat ]]; then
      skip=1
      break
    fi
  done
  [ "$skip" -eq 1 ] && continue

  for pattern in "${PATTERNS[@]}"; do
    # Read from the index (tracked snapshot) not stale HEAD content
    if git show ":$file" 2>/dev/null | grep -qE "$pattern"; then
      echo "ERROR: Potential credential value detected in tracked file: $file" >&2
      STATUS=1
      break
    fi
  done
done < <(git ls-files)

exit $STATUS
