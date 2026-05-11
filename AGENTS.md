# Agents Guide

## Project Summary

This repository is a beginner-friendly full-stack learning project that builds a photo-only Instagram clone.

The app is designed to help a learner understand how a real full-stack mobile product fits together from frontend to backend to database.

## Main Goal

Build and improve a working Instagram-style app while keeping the codebase approachable for learning.

Important project goals:

- Keep the architecture simple enough for a beginner to follow.
- Prefer clear, readable code over clever abstractions.
- Ship features in small, understandable steps.
- Keep documentation and progress notes updated so a future agent can resume work quickly.

## Stack

- Frontend: Flutter
- Frontend state/navigation/networking: Riverpod, GoRouter, Dio
- Backend: NestJS
- Database: PostgreSQL
- ORM: Prisma
- Auth: JWT
- File storage: local uploads in `backend/uploads`

## Repository Structure

- `backend/`: NestJS API, Prisma schema, uploads, auth, posts, likes, comments
- `frontend/instagramflutterapp/`: Flutter application
- `docs/`: setup guides, architecture notes, API docs, lesson plan
- `PROGRESS.md`: current handoff and latest verified status
- `README.md`: onboarding, setup, stack, and core feature overview

## Current Product State

The app already has a working full-stack foundation and includes:

- User signup and login
- JWT-based authenticated session flow
- Feed retrieval
- Photo upload with optional caption
- Likes and unlikes
- Comments and comment deletion
- Post deletion
- Native share flow
- Home profile summary
- Logout confirmation
- Edit-profile flow with display name update and profile photo upload
- App-wide keyboard dismiss support through the shared text field components

## Current Priority

The next best step, based on `PROGRESS.md`, is to add widget coverage for the edit-profile flow so recent profile work is protected by automated tests instead of only manual verification.

## How To Work In This Repo

- Read `PROGRESS.md` and `README.md` first at the start of a new session.
- Use `PROGRESS.md` as the source of truth for latest status, recent work, and known issues.
- Keep changes beginner-friendly and avoid unnecessary architectural complexity.
- When adding form fields, prefer the shared `AppTextField` so keyboard-dismiss behavior stays consistent across the app.
- When changing API behavior, keep frontend and backend contracts in sync.
- Update `PROGRESS.md` after meaningful code changes.

## Important Environment Notes

- Backend API base URL depends on the platform running Flutter.
- `localhost` works for macOS and iOS simulator.
- Android emulator should use `10.0.2.2`.
- Physical devices should use the machine's Wi-Fi IP.
- Do not commit real `.env` files or secrets.

## Recommended Starting Points

If an agent is asked to continue product work, check these first:

1. `PROGRESS.md`
2. `README.md`
3. `docs/ARCHITECTURE.md`
4. `docs/API.md`
5. the relevant feature folder in `frontend/instagramflutterapp/lib/src/`
6. the matching backend area in `backend/src/`

## Success Criteria

Good work in this project should:

- preserve a working end-to-end app
- improve clarity for a beginner reader
- include focused verification where practical
- Run relevant tests when possible.
- keep docs and handoff notes aligned with the actual codebase
- Update `PROGRESS.md` after meaningful changes.
