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

The project has a working full-stack foundation. The main learning focus is now moving from setup into user-facing Instagram clone features, UI polish, testing, and reliable daily development workflow.

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

### 2026-05-01 - Home Page User Profile

Goal:

- Add user profile information to the home page.

Expected result:

- The home page should show a basic signed-in user profile area alongside the feed experience.

Follow-up needed:

- Recheck the final UI on emulator/simulator.
- Confirm the profile data comes from the correct auth/current-user source.
- Add or update tests if the profile UI has stable widgets or providers.

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

### Environment Files

Do not commit real `.env` files. Keep example files like `.env.example` in Git, but keep local secrets out of Git.

## Next Recommended Steps

1. Re-run the project from a clean restart using the README commands.
2. Create a `RUNBOOK.md` with exact daily startup commands.
3. Verify the home page profile UI on at least one emulator or simulator.
4. Review the current auth/current-user state flow.
5. Add profile edit support.
6. Add profile image upload.
7. Add focused Flutter tests for home/profile UI.
8. Add backend tests for profile-related endpoints when those endpoints exist.

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
