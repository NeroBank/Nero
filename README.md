# NERO Offline Bible

NERO is an English-language, offline King James Version (KJV) Bible reader for Android.

## Features

- All 66 books of the King James Version are downloaded during the GitHub Actions build and bundled inside the Android application.
- Read books, chapters, and verses without an internet connection after installation.
- Search the text of the Bible offline.
- Save and remove favourite verses. Saved verses are stored locally on the device.
- Original NERO red-and-white visual theme, banner, and launcher artwork are retained.
- No Supabase, Firebase, account registration, email verification, or online sign-in is used.
- All application interface text is English.

## Build the Android APK

1. Open the `NeroBank/Nero` GitHub repository.
2. Open **Actions**.
3. Select **Build NERO Offline Android APK**.
4. Select **Run workflow** and confirm.
5. When the workflow succeeds, open its run and download the `NERO-Offline-Android-APK` artifact.
6. Extract the artifact ZIP and install the APK on the Android device.

The workflow downloads and validates all 66 KJV books before building. The Bible text is bundled in the APK; internet access is needed only during the build to obtain the source data and dependencies.

## Artwork locations

- Home banner: `assets/images/bible_banner.png`
- Launcher icon and in-app mark: `assets/images/icon/nero_launcher.png`

## Local development

Run `python tool/download_kjv.py`, then `flutter pub get`, `dart run flutter_launcher_icons`, and `flutter build apk --release`.
