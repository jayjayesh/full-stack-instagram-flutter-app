# Progress

## Current Goal

Build a photo-only Instagram clone as a beginner-friendly full-stack learning project.

The app uses:

- Flutter frontend
- NestJS backend
- PostgreSQL database
- Prisma ORM
- Local backend uploads for photos

## Current Status

The project has a working full-stack foundation and now includes a more complete signed-in home experience. Recent work added a profile summary on the home page, improved logout UX, fixed feed state when switching accounts, and added a regression test around that session-change behavior.

## Completed So Far

### Project Foundation

- Created full-stack project structure.
- Added backend and frontend folders.
- Added project documentation in `docs/`.
- Updated root `README.md` with setup, architecture, API, and learning guide links.

### Backend Foundation

- Added NestJS backend.
- Added Prisma and PostgreSQL setup.
- Added JWT-based authentication.
- Added seeded test account.
- Added post, like, comment, and upload-related backend areas.
- Added local upload storage in `backend/uploads`.

### Flutter Foundation

- Added Flutter app under `frontend/instagramflutterapp`.
- Added auth flow basics.
- Added feed, post, like, comment, delete, upload, and share-related frontend areas.
- Added app icon updates.
- Updated Android and iOS app name to `instagram clone`.
- Added app configuration for backend API base URLs.

### Documentation

- Added lesson plan and setup documentation.
- Added backend, frontend, architecture, and API docs.
- Updated root-level `README.md` so the project is easier to understand after reopening it.

## Recent Work

### 2026-05-01 - Home Profile, Logout UX, and Session-Aware Feed

What changed:

- Added a profile summary section to the home page so the signed-in user can see their name, handle, email, post count, like count, and comment count alongside the feed.
- Improved the empty-feed and error states so the home screen still feels personalized even when there are no posts yet or the feed load fails.
- Added a logout confirmation dialog and supporting translation updates for logout-related labels.
- Fixed a session bug where feed data from one account could remain visible after logging out and signing in as a different user.
- Added a focused Riverpod regression test to verify the feed clears and reloads for the next signed-in user.
- Cleaned up a small unnecessary home-page item in the latest commit.

Files touched:

- `frontend/instagramflutterapp/lib/src/features/home/presentation/screens/home_page.dart`
- `frontend/instagramflutterapp/lib/src/features/home/presentation/widgets/profile_section_card.dart`
- `frontend/instagramflutterapp/lib/src/features/home/presentation/widgets/profile_stat_card.dart`
- `frontend/instagramflutterapp/lib/src/features/posts/presentation/providers/posts_provider.dart`
- `frontend/instagramflutterapp/lib/src/features/posts/presentation/screens/create_post_screen.dart`
- `frontend/instagramflutterapp/lib/src/shared/widgets/app_text_field.dart`
- `frontend/instagramflutterapp/lib/src/theme/theme.dart`
- `frontend/instagramflutterapp/assets/translations/en.json`
- `frontend/instagramflutterapp/assets/translations/es.json`
- `frontend/instagramflutterapp/test/feed_provider_test.dart`

Tests run:

- `cd frontend/instagramflutterapp && flutter test test/feed_provider_test.dart`
  Result: passed.
- `cd frontend/instagramflutterapp && flutter analyze`
  Result: completed with 3 info-level lints:
  - `lib/src/shared/helpers/show_toast.dart:60`
  - `lib/src/shared/helpers/show_toast.dart:66`
  - `lib/src/theme/theme.dart:292`

## Known Issues And Watch Points

### Media Permissions

Media picker permissions need careful testing on Android and iOS.

Important checks:

- Android emulator
- Physical Android device
- iOS simulator
- Physical iPhone

### Backend Base URL

The correct API base URL depends on where the Flutter app is running:

- macOS app: `http://localhost:3000/api`
- iOS simulator: `http://localhost:3000/api`
- Android emulator: `http://10.0.2.2:3000/api`
- Physical Android or iPhone: use the Mac Wi-Fi IP, for example `http://192.168.1.25:3000/api`

### Flutter Material 3 Colors

Some button, app bar, floating action button, and icon colors may come from Flutter Material 3 theme defaults. When UI colors look unexpected, check the app theme first.

### Pending UI Verification

The new profile section, logout confirmation flow, and session-switching feed behavior still need manual verification on an emulator or simulator to confirm the current-user data and stats look correct in real navigation flow.

### Analyzer Notes

`flutter analyze` currently reports 3 info-level issues:

- `frontend/instagramflutterapp/lib/src/shared/helpers/show_toast.dart:60`
- `frontend/instagramflutterapp/lib/src/shared/helpers/show_toast.dart:66`
- `frontend/instagramflutterapp/lib/src/theme/theme.dart:292`

### Environment Files

Do not commit real `.env` files. Keep example files like `.env.example` in Git, but keep local secrets out of Git.

## Next Recommended Steps

1. Manually test the real auth flow on an emulator or simulator: login as user A, logout, login as user B, and confirm the home profile card and feed stats update to the new account.
2. Add a widget test for the home page profile section and logout confirmation dialog so the recent UI work has direct test coverage beyond the provider-level regression test.
3. Clean up the 3 current analyzer info warnings in `show_toast.dart` and `theme.dart`.
4. Continue the profile feature set with profile edit support and profile image upload after the current home/session flow is verified.

## Useful Commands

### Check Git Changes

```bash
git status --short
git diff --stat
```

### Start Backend

```bash
cd backend
npm run start:dev
```

### Start Flutter App

```bash
cd frontend/instagramflutterapp
flutter pub get
flutter run
```

### Flutter Checks

```bash
cd frontend/instagramflutterapp
flutter analyze
flutter test
```

### Backend Checks

```bash
cd backend
npm run lint
npm test
```

## How To Use This File With Codex

At the start of a new session, ask:

```text
Read PROGRESS.md and README.md first, then tell me the current project status and the next best step.
```

After Codex changes code, ask:

```text
Update PROGRESS.md with what changed, files touched, tests run, known issues, and the next recommended step.
```

When you are confused about what changed, ask:

```text
Compare git diff with PROGRESS.md and explain the changes in beginner-friendly language.
```
