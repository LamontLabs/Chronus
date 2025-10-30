#!/usr/bin/env bash
set -euo pipefail

echo "== Verifying Android build environment =="

fail=0

check() {
  if [[ -z "${!1:-}" ]]; then
    echo "Missing env: $1"
    fail=1
  else
    echo "OK: $1"
  fi
}

check EAS_TOKEN
check ANDROID_PACKAGE
check PLAY_TRACK

echo -n "Node: "; node -v || { echo "Node missing"; fail=1; }
echo -n "pnpm: "; pnpm -v || { echo "pnpm missing"; fail=1; }
echo -n "Expo: "; npx expo --version || { echo "Expo CLI missing"; fail=1; }
echo -n "EAS: "; npx eas --version || { echo "EAS CLI missing"; fail=1; }

if [[ $fail -ne 0 ]]; then
  echo "Environment check failed."
  exit 1
fi

echo "Environment ready."
