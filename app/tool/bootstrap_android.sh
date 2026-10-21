#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
command -v flutter >/dev/null || { echo "Flutter SDK is required"; exit 1; }
if [[ ! -f android/gradlew ]]; then flutter create --platforms=android .; fi
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter build apk --debug
