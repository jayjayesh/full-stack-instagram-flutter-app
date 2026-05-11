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

The project has a working full-stack foundation and now includes profile editing plus a more complete comment experience. Users can edit their profile, confirm comment deletion before it happens, edit their own comments, and see post comment labels adapt to the current comment count.

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

### 2026-05-11 - Comment Management UX, Comment Editing, and Flutter CI

What changed:

- Added a delete-comment confirmation dialog in the post comments sheet so comment removal now matches the safer confirmation pattern already used for logout and post deletion.
- Updated the post comment CTA so the label changes with the current comment count instead of always showing a single static message.
- Added backend comment editing support with a new update-comment DTO plus controller and service handling.
- Connected the Flutter post repository and comments sheet UI to the new edit-comment API flow.
- Added widget coverage for comment deletion confirmation, comment-count label behavior, and editing an owned comment.
- Added a GitHub Actions workflow at `.github/workflows/flutter-ci.yml` for the Flutter app.
- Configured the workflow to run on pushes to `production` and pull requests targeting `production`.
- Kept the workflow focused on frontend validation by running `flutter pub get`, `flutter analyze --no-fatal-infos`, and `flutter test` from `frontend/instagramflutterapp`.
- Added a small CI safeguard that creates `.env` from `.env.example` only when the runner does not already have a tracked `.env` file available.
- Added `AGENTS.md` so future agents have a project-specific guide for the repo structure, stack, workflow expectations, and current priority.

Known issues / notes:

- The repository currently has `main` as the only existing branch. The new workflow will stay dormant until a real `production` branch exists on GitHub or locally and is pushed.
- `flutter analyze` currently reports 8 info-level lints. Three are older style items in app code, and five are `prefer_const_constructors` infos in widget tests.
- The highest-value remaining gap is still edit-profile widget coverage. That flow has manual verification, but it does not yet have dedicated automated widget tests.

### 2026-05-06 - Delete Confirmation and App-Wide Keyboard Dismiss

What changed:

- Added a confirmation dialog before deleting an owned post so the delete flow now matches the logout confirmation UX.
- Added translation strings for post deletion confirmation in English and Spanish.
- Added app-wide keyboard dismissal when tapping outside shared text fields by wiring outside-tap handling into the shared `AppTextField`.
- Added a root `TapRegionSurface` so the outside-tap keyboard behavior works consistently across screens and sheets that use the shared text field.
- Added focused widget coverage for the delete confirmation flow and for the shared text field outside-tap callback wiring.
- Manually verified that keyboard dismiss on outside tap works correctly in the real app flow.
- Manually verified that the profile-edit flow works correctly, including editing profile data and saving changes successfully.
- Manually verified that owned-post delete confirmation works correctly in the real app flow.
- Confirmed that the 3 existing analyzer info warnings in `show_toast.dart` and `theme.dart` can remain out of scope for now.

Known issues / notes:

- The keyboard-dismiss behavior is implemented through Flutter's `onTapOutside` support on the shared text field plus a root `TapRegionSurface`. Manual verification is complete, but future form screens should continue using the shared `AppTextField` so this behavior stays consistent.
- The focused keyboard test verifies callback wiring rather than a full synthetic end-to-end focus transition, because Flutter widget tests do not reliably reproduce real outside-tap focus behavior in this case.

### 2026-05-04 - Progress Refresh and Current Verification Status

What changed:

- Refreshed this handoff note against the current repository state after the profile-edit work landed.
- Re-ran the focused frontend checks and backend build to confirm the current verification status instead of relying only on the previous summary.
- Found that the home-page widget test is now out of sync with the UI copy. The test still expects `Your activity summary`, while the widget currently renders `Your activity`.

### 2026-05-01 - Home Profile, Logout UX, and Session-Aware Feed

What changed:

- Added a profile summary section to the home page so the signed-in user can see their name, handle, email, post count, like count, and comment count alongside the feed.
- Improved the empty-feed and error states so the home screen still feels personalized even when there are no posts yet or the feed load fails.
- Added a logout confirmation dialog and supporting translation updates for logout-related labels.
- Fixed a session bug where feed data from one account could remain visible after logging out and signing in as a different user.
- Added a focused Riverpod regression test to verify the feed clears and reloads for the next signed-in user.
- Cleaned up a small unnecessary home-page item in the latest commit.

### 2026-05-04 - Manual Verification Complete and Home Widget Tests

What changed:

- Confirmed through manual testing that the auth/session flow works correctly when logging in, logging out, and switching accounts.
- Confirmed the home profile card updates correctly in the real app flow.
- Added widget tests for the home page profile summary content.
- Added widget coverage for the logout confirmation dialog, including cancel and confirm behavior with navigation to the login route.

### 2026-05-04 - Profile Editing and Profile Photo Upload

What changed:

- Added a backend `PATCH /api/auth/profile` endpoint for updating the signed-in user's display name and optional profile photo upload.
- Reused local upload storage so profile photos are served through the existing `/uploads` path.
- Extended the Flutter auth service, repository, and auth controller to support profile updates and refresh the in-memory signed-in user.
- Added a new edit-profile screen where the user can choose a new gallery image and update their display name.
- Added an edit action to the home profile card so the new screen is reachable from the signed-in home experience.
- Refreshed the feed after a successful profile update so the user's posts pick up the latest name and photo without requiring a full sign-out/sign-in cycle.
- Added translation strings for the new profile-editing flow.
- Updated test doubles to match the new auth repository contract.

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

1. Add focused widget coverage for the edit-profile flow so the recent profile screen, save action, validation, and refresh behavior are protected by automated tests instead of only manual verification.
2. After the edit-profile tests land, consider a focused backend or integration-style check for comment editing so both the new DTO validation and frontend repository flow stay aligned.
3. Keep routing future editable form inputs through the shared `AppTextField` so keyboard-dismiss behavior remains app-wide by default.

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
