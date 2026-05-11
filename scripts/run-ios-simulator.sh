#!/usr/bin/env bash
set -euo pipefail

SCHEME="HouseholdLedger"
PROJECT="HouseholdLedger.xcodeproj"
BUNDLE_ID="com.local.HouseholdLedger"
DERIVED_DATA_PATH="/private/tmp/HouseholdLedgerSimulatorDerivedData"
APP_PATH="${DERIVED_DATA_PATH}/Build/Products/Debug-iphonesimulator/${SCHEME}.app"

cd "$(dirname "$0")/.."

if ! xcodebuild -list -project "${PROJECT}" >/dev/null; then
  echo "Xcode project not found or cannot be opened: ${PROJECT}" >&2
  exit 1
fi

DEVICE_ID="${SIMULATOR_UDID:-}"

if [[ -z "${DEVICE_ID}" ]]; then
  DEVICE_ID="$(
    xcrun simctl list devices available |
      grep "iPhone" |
      grep "(Booted)" |
      sed -E 's/.*\(([0-9A-F-]{36})\).*/\1/' |
      head -n 1 || true
  )"
fi

if [[ -z "${DEVICE_ID}" ]]; then
  DEVICE_ID="$(
    xcrun simctl list devices available |
      grep "iPhone" |
      grep "(Shutdown)" |
      sed -E 's/.*\(([0-9A-F-]{36})\).*/\1/' |
      head -n 1 || true
  )"
fi

if [[ -z "${DEVICE_ID}" ]]; then
  echo "No available iPhone simulator found." >&2
  exit 1
fi

open -a Simulator
xcrun simctl boot "${DEVICE_ID}" 2>/dev/null || true
xcrun simctl bootstatus "${DEVICE_ID}" -b

xcodebuild \
  -project "${PROJECT}" \
  -scheme "${SCHEME}" \
  -configuration Debug \
  -destination "generic/platform=iOS Simulator" \
  -derivedDataPath "${DERIVED_DATA_PATH}" \
  CODE_SIGNING_ALLOWED=NO \
  build

xcrun simctl install "${DEVICE_ID}" "${APP_PATH}"
xcrun simctl launch "${DEVICE_ID}" "${BUNDLE_ID}"

echo "Launched ${BUNDLE_ID} on simulator ${DEVICE_ID}."
