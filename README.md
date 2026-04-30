# Full Stack Instagram Flutter App

This repository contains a photo-focused Instagram clone built with a Flutter frontend and a NestJS backend. It is structured as both a working full-stack app and a beginner-friendly learning project, with supporting guides in [`docs/`](docs).

## Stack

- Frontend: Flutter, Riverpod, GoRouter, Dio
- Backend: NestJS, JWT auth, Prisma
- Database: PostgreSQL
- File storage: local uploads in `backend/uploads`

## Project Structure

```text
backend/                         NestJS API, Prisma schema, uploads
frontend/instagramflutterapp/    Flutter application
docs/                            Setup guides, architecture notes, lesson plan
```

## Quick Start

### Requirements

- Flutter SDK
- Node.js 20+
- PostgreSQL

### 1. Start the backend

```bash
cd backend
npm install
cp .env.example .env
npm run prisma:migrate
npm run seed
npm run start:dev
```

Optional database browser:

```bash
cd backend
npm run prisma:studio
```

Backend endpoints:

- Health: `http://localhost:3000/health`
- API base: `http://localhost:3000/api`
- Uploaded files: `http://localhost:3000/uploads/<filename>`

### 2. Start the Flutter app

```bash
cd frontend/instagramflutterapp
flutter pub get
flutter run
```

Set `API_BASE_URL` in the Flutter `.env` file to:

- `http://localhost:3000/api` for macOS or iOS simulator
- `http://10.0.2.2:3000/api` for Android emulator

### 3. Use the seeded account

After running the backend seed:

- Email: `student@example.com`
- Password: `password123`

## Core Features

- User signup, login, and current-user auth flow with JWT
- Photo uploads with optional captions
- Feed retrieval with author, likes, comments, and liked-state
- Like and unlike posts
- Add and delete comments
- Delete your own posts and comments
- Native share flow on the Flutter side

## Request Flow

### Backend

1. Controller receives the request.
2. DTO validation checks the payload.
3. JWT guards protect authenticated routes.
4. Service runs business logic.
5. Prisma reads or writes PostgreSQL.
6. JSON response is returned to Flutter.

### Frontend

1. Screen collects user input.
2. Riverpod provider calls a repository.
3. Repository uses Dio to call the backend.
4. JWT is attached to protected requests.
5. Provider updates UI state.
6. Widgets rebuild with the latest data.

## Important Code Areas

### Backend

- `backend/src/auth`: signup, login, JWT, current user
- `backend/src/posts`: posts, likes, comments, uploads
- `backend/prisma/schema.prisma`: data model and relationships

### Frontend

- `frontend/instagramflutterapp/lib/src/services/auth_service.dart`: auth API calls
- `frontend/instagramflutterapp/lib/src/config/app_config.dart`: Dio and app config
- `frontend/instagramflutterapp/lib/src/features/posts`: feed, upload, likes, comments, share
- `frontend/instagramflutterapp/lib/src/features/home/presentation/screens/home_page.dart`: main feed screen

## API Overview

Base path: `/api`

### Auth

- `POST /auth/signup`
- `POST /auth/login`
- `GET /auth/me`

### Posts

- `POST /posts`
- `GET /posts/feed`
- `DELETE /posts/:id`

### Likes

- `POST /posts/:id/like`
- `DELETE /posts/:id/like`

### Comments

- `GET /posts/:id/comments`
- `POST /posts/:id/comments`
- `DELETE /comments/:id`

See [`docs/API.md`](docs/API.md) for example request bodies and auth details.

## Docs Guide

Read these in this order if you are learning or onboarding:

1. [`docs/01_LESSON_PLAN.md`](docs/01_LESSON_PLAN.md)
2. [`docs/02_SETUP.md`](docs/02_SETUP.md)
3. [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)
4. [`docs/API.md`](docs/API.md)
5. [`docs/BACKEND.md`](docs/BACKEND.md)
6. [`docs/FRONTEND.md`](docs/FRONTEND.md)
7. [`docs/FRONTEND_SETUP.md`](docs/FRONTEND_SETUP.md)
8. [`docs/FRONTEND_ARCHITECTURE.md`](docs/FRONTEND_ARCHITECTURE.md)

## Notes

- Uploads are stored locally first to keep the learning flow simple.
- The current upload approach can later be replaced with S3, Cloudinary, Supabase Storage, or Firebase Storage while keeping the database `imageUrl` pattern.
