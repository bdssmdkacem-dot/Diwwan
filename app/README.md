# Diwwan Android prototype

Flutter starter for a local-first lecture and report notebook.

## Current milestone
- Arabic RTL-first interface (initial prototype).
- Local SQLite notes and reports.
- Audio recording in private app storage.
- Device speech-to-text locale selection for Arabic/French/English.
- Deterministic extractive summary only; no generative AI model integrated yet.

## Build
Install Flutter stable and Android SDK, then from this directory run:

```bash
flutter create --platforms=android .
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

## Known gaps
- No successful APK build is claimed until CI runs successfully.
- Recognition may use a vendor service or network; offline behavior must be verified per device and language pack.
- PDF/DOCX export, playback, full UI localization, and recording interruption recovery remain to be implemented.
- `flutter create` generates the Gradle wrapper, Kotlin activity and resources; review generated platform files before release.

## Acceptance checklist
- [ ] dependency resolution, analyzer and tests pass
- [ ] APK builds and installs on Android
- [ ] local CRUD and long text survive restart
- [ ] recording lifecycle tested on physical device
- [ ] Arabic/French/English speech recognition tested separately
- [ ] offline/network behavior verified
- [ ] on-device generative AI integrated and benchmarked
- [ ] PDF/DOCX export and full localization tested
