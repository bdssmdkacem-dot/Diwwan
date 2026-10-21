# Diwwan (دوّن)

Android-first, offline-first lecture and report assistant.

## Current status

This repository is the project home for an early Flutter prototype. The initial milestone focuses on local notes, lecture recording, and device speech recognition in Arabic, French, and English.

**Not yet release-ready:** a successful Flutter/Android build, on-device QA, complete localization, document export, and real on-device generative AI still need verification/implementation.

## Planned milestones

1. Flutter app foundation, Arabic RTL interface, local SQLite storage.
2. Audio recording to private app storage and speech-to-text language selection.
3. Proper multilingual UI and robust recording lifecycle.
4. PDF/DOCX export and report templates.
5. Evaluate and integrate an on-device multilingual LLM; do not describe template summaries as generative AI.
6. CI, Android APK build, tests, and physical-device acceptance.

## Build

Install Flutter stable and Android SDK, then run:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

See `app/` for the Flutter project and its README for implementation limitations and acceptance criteria.
