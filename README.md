# Nero Banks Prediction (NBP) — Android APK build package

This is a Flutter prototype for testing the NBP interface. The included GitHub Actions workflow can build an Android APK in GitHub's cloud runner, so a local computer with Flutter is not required.

## Important status
- The current screen still uses clearly labelled fictional/demo fixtures.
- This package does **not** yet connect to live API-Football data.
- The workflow builds an APK; it does not install it on your phone or deploy a backend.
- Do not put API keys, passwords, or secrets in Dart source or this repository.

## Cloud APK build
1. Put the project files at the root of your GitHub repository. The root must contain `pubspec.yaml`, `lib/main.dart`, and `.github/workflows/build-android-apk.yml`.
2. Open the repository's **Actions** tab.
3. Select **Build NBP Android APK**.
4. Tap **Run workflow**, choose `main`, and confirm.
5. When the run completes successfully, open that run and download the `NBP-Android-APK` artifact. Extract the downloaded artifact ZIP to get `app-release.apk`.
6. Open the APK on your Android phone and follow Android's installation prompts. Only install APKs you built and trust.

The workflow also runs automatically after a push to `main`.

## Build locally (if you later have a computer)
Run `flutter pub get` and `flutter build apk --release`. The APK is written to `build/app/outputs/flutter-apk/app-release.apk`.

## Next stage: live data
A secure backend still needs to be deployed and configured with an API-Football key stored as a Cloudflare Worker secret. The Flutter app must then be updated to use the backend endpoint. Never embed the API key in the mobile app.
