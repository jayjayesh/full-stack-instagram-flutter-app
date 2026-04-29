# Setup

## Requirements

- Flutter SDK
- Node.js 20 or newer
- PostgreSQL

## Backend

```bash
cd backend
npm install
cp .env.example .env
npm run prisma:migrate
npm run seed
npm run start:dev
```

Backend URLs:

- Health check: `http://localhost:3000/health`
- API base URL: `http://localhost:3000/api`
- Uploaded photos: `http://localhost:3000/uploads/<filename>`

## Frontend

```bash
cd frontend/instagramflutterapp
flutter pub get
flutter run
```

The Flutter `.env` uses:

```text
API_BASE_URL=http://localhost:3000/api
```

For Android emulator, change it to:

```text
API_BASE_URL=http://10.0.2.2:3000/api
```

## Test Login

After running the seed:

- Email: `student@example.com`
- Password: `password123`
