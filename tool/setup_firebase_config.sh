#!/usr/bin/env bash
# shellcheck disable=SC2016
#
# Restore Firebase client configuration from a secure local directory.
#
# Usage: ./tool/setup_firebase_config.sh [source-dir]
#
# Default source directory: $HOME/.config/daily_stanza/firebase
# Override via first argument or FIREBASE_CONFIG_DIR environment variable.
#
# Required source files:
#   firebase_options.dart   → lib/firebase_options.dart
#   google-services.json    → android/app/google-services.json
#   GoogleService-Info.plist → ios/Runner/GoogleService-Info.plist

set -euo pipefail

if [ -n "${FIREBASE_CONFIG_DIR:-}" ]; then
  SRC="$FIREBASE_CONFIG_DIR"
elif [ $# -ge 1 ]; then
  SRC="$1"
else
  SRC="$HOME/.config/daily_stanza/firebase"
fi

FILES=(
  firebase_options.dart:lib/firebase_options.dart
  google-services.json:android/app/google-services.json
  GoogleService-Info.plist:ios/Runner/GoogleService-Info.plist
)

# Phase 1: validate that all three source files exist and are non-empty
for entry in "${FILES[@]}"; do
  src_name="${entry%%:*}"
  src_file="$SRC/$src_name"

  if [ ! -f "$src_file" ]; then
    echo "ERROR: Missing source file: $src_file" >&2
    exit 1
  fi

  if [ ! -s "$src_file" ]; then
    echo "ERROR: Source file is empty: $src_file" >&2
    exit 1
  fi
done

# Phase 2: every validation passed — create destinations and copy all three
for entry in "${FILES[@]}"; do
  src_name="${entry%%:*}"
  dest="${entry#*:}"
  src_file="$SRC/$src_name"

  dest_dir="$(dirname "$dest")"
  mkdir -p "$dest_dir"
  install -m 600 "$src_file" "$dest"
done

echo "Firebase client configuration restored successfully."
