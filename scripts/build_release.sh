#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

ENV_FILE="${RELEASE_ENV_FILE:-.release.env}"
if [[ -f "$ENV_FILE" ]]; then set -a; . "$ENV_FILE"; set +a; fi

APP_NAME="LinkDrop"
DIST_DIR="${DIST_DIR:-dist}"
REQUIRE_SIGNING="${REQUIRE_SIGNING:-1}"

make clean build

identity="${CODE_SIGN_IDENTITY:-}"
if [[ -z "$identity" ]]; then identity="$(security find-identity -v -p codesigning 2>/dev/null | grep 'Developer ID Application' | head -1 | sed 's/.*"\(.*\)"/\1/' || true)"; fi
if [[ "$REQUIRE_SIGNING" == "1" && -z "$identity" ]]; then echo "No Developer ID Application signing identity found."; exit 1; fi
if [[ -n "$identity" ]]; then
  codesign --force --options runtime --sign "$identity" --timestamp "$APP_NAME.app"
  codesign --verify --strict --deep --verbose=2 "$APP_NAME.app"
fi

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"
ditto "$APP_NAME.app" "$DIST_DIR/$APP_NAME.app"
echo "App bundle created: $DIST_DIR/$APP_NAME.app"
