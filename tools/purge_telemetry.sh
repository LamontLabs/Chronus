#!/usr/bin/env bash
set -euo pipefail
DIR="assets/telemetry"
DAYS="${1:-30}"

echo "== Purging telemetry older than $DAYS days from $DIR =="
find "$DIR" -type f -mtime "+$DAYS" -print -delete || true
echo "OK"
