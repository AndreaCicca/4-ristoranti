#!/bin/bash

# Detect and summarize Xcode build errors for this project.
# Usage:
#   ./detect_build_errors.sh
#   ./detect_build_errors.sh Debug

set -u

PROJECT_NAME="ristoranti"
SCHEME_NAME="ristoranti"
CONFIGURATION="${1:-Release}"
BUILD_DIR="build"
LOG_DIR="$BUILD_DIR/logs"
DERIVED_DATA_DIR="$BUILD_DIR/DerivedData"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
RAW_LOG="$LOG_DIR/build_${CONFIGURATION}_${TIMESTAMP}.log"
ERROR_REPORT="$LOG_DIR/build_errors_${CONFIGURATION}_${TIMESTAMP}.txt"

mkdir -p "$LOG_DIR"

echo "==> Avvio build: progetto=$PROJECT_NAME, scheme=$SCHEME_NAME, configuration=$CONFIGURATION"
echo "==> Log completo: $RAW_LOG"

# Run build and capture full output, preserving xcodebuild exit status.
set +e
xcodebuild -project "$PROJECT_NAME.xcodeproj" \
           -scheme "$SCHEME_NAME" \
           -configuration "$CONFIGURATION" \
           -derivedDataPath "$DERIVED_DATA_DIR" \
           -destination 'platform=macOS' \
           CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO \
           build 2>&1 | tee "$RAW_LOG"
BUILD_STATUS=${PIPESTATUS[0]}
set -e

{
  echo "Build status: $BUILD_STATUS"
  echo "Report generated: $(date)"
  echo ""

  echo "===== ERROR LINES (xcodebuild) ====="
  if grep -nE "(^|[[:space:]])error:" "$RAW_LOG" >/dev/null; then
    grep -nE "(^|[[:space:]])error:" "$RAW_LOG"
  else
    echo "Nessuna riga con 'error:' trovata nel log."
  fi
  echo ""

  echo "===== TEST FAILURES ====="
  if grep -nE "(FAILED|\*\* TEST FAILED \*\*|Assertion failed|fatal error:)" "$RAW_LOG" >/dev/null; then
    grep -nE "(FAILED|\*\* TEST FAILED \*\*|Assertion failed|fatal error:)" "$RAW_LOG"
  else
    echo "Nessun test failure rilevato nel log."
  fi
  echo ""

  echo "===== LAST 120 LOG LINES ====="
  tail -n 120 "$RAW_LOG"
} > "$ERROR_REPORT"

if [ "$BUILD_STATUS" -eq 0 ]; then
  echo "==> Build completata con successo."
  echo "==> Report disponibile in: $ERROR_REPORT"
  exit 0
fi

echo "==> Build fallita con codice: $BUILD_STATUS"
echo "==> Report errori disponibile in: $ERROR_REPORT"
echo ""
echo "Prime righe errore:"
grep -nE "(^|[[:space:]])error:" "$RAW_LOG" | head -n 15 || true

exit "$BUILD_STATUS"
