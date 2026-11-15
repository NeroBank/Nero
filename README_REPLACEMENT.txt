NERO OFFLINE BIBLE — REPLACEMENT FILES

This ZIP contains two corrected project files. It is not a complete copy of the app.

1. Open your Nero GitHub repository.
2. Replace tool/download_kjv.py with the file in this ZIP.
3. Create .github/workflows/build_nero.yml and paste/use the workflow file in this ZIP.
4. Keep your existing pubspec.yaml, lib/main.dart, logo, and banner files unchanged.
5. Confirm the existing banner is at assets/icon/images/bible_banner.png and launcher icon is at assets/icon/nero_launcher.png.
6. In GitHub repository Settings > Secrets and variables > Actions, make sure these secrets exist:
   - SUPABASE_URL
   - SUPABASE_ANON_KEY
7. Commit the two replacement files to main. The workflow will download all 66 KJV books during the build and bundle them into the APK.
8. Open Actions > Build NERO Android APK and download the NERO-Android-APK artifact when it succeeds.

OFFLINE BEHAVIOUR
The KJV text is bundled inside the APK, so Bible reading does not need mobile data or Wi-Fi after installation. Supabase registration, email verification, sign-in, and sign-out still need an internet connection.

IMPORTANT
Do not delete or replace lib/main.dart, pubspec.yaml, or your existing artwork with this ZIP. The ZIP only contains the two corrected replacement files and these instructions.
