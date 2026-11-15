# NERO — Read, Reflect & Grow

Flutter Android Bible app starter using the King James Version (KJV), Supabase email authentication, and the NERO red/gold visual identity.

## Included
- Flutter app source (`lib/main.dart`)
- NERO home banner and Android launcher artwork
- Supabase email/password sign-up, sign-in, email verification flow, password reset and sign-out
- Bible book/chapter reader, saved verses, book search
- GitHub Actions Android APK workflow
- Script to fetch and normalize the complete 66-book KJV data set

## Important: add Supabase credentials
In the GitHub repository, open **Settings → Secrets and variables → Actions → New repository secret**.
Create:
- `SUPABASE_URL` — your Supabase project URL
- `SUPABASE_ANON_KEY` — your Supabase publishable/anon key

Never add the Supabase service-role key to the mobile app.

In Supabase Authentication settings, enable email confirmations and set the allowed redirect URLs if you configure a custom email redirect later. The app currently uses Supabase's default confirmation flow.

## Put these files in your repository
Copy the contents of this package into the root of your empty `Nero` repository, preserving folder names:
- `pubspec.yaml`
- `lib/main.dart`
- `assets/images/bible_banner.png`
- `assets/icon/nero_launcher.png`
- `tool/download_kjv.py`
- `.github/workflows/build_nero.yml`

The workflow creates the Android platform folder, downloads all 66 KJV book files into `assets/bible/`, generates the launcher icon, and builds the release APK.

## First build
1. Commit and push the files to `main` (or `master`).
2. Open the repository's **Actions** tab.
3. Select **Build NERO Android APK**.
4. When successful, open the run and download the `NERO-Android-APK` artifact.

## Bible data
The workflow fetches the KJV book JSON files from the public `renniemaharaj/kjv-bible` repository and normalizes them into NERO's local asset format. The KJV is public domain in many jurisdictions; review source provenance and applicable local law before distribution.

## Current prototype scope
The supplied Flutter code implements welcome, registration, sign-in, home dashboard, Bible book/chapter navigation, saved verses, and account sign-out. Audio playback, devotional publishing, prayer journal, full-text verse search, and in-app offline download management are follow-on features, not represented as completed in this starter.
