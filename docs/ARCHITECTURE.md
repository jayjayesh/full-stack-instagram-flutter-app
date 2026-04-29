# Architecture Notes

## Backend Flow

1. Controller receives an HTTP request.
2. DTO validation checks the request body.
3. Guard checks JWT for protected routes.
4. Service runs business logic.
5. Prisma reads or writes PostgreSQL rows.
6. Controller returns JSON to Flutter.

## Frontend Flow

1. Screen collects user input.
2. Riverpod provider calls a repository.
3. Repository uses Dio to call the backend.
4. Dio attaches the saved JWT token.
5. Provider updates UI state.
6. Widget rebuilds with the latest data.

## Why Local Uploads First?

Local uploads are easy to understand because the file is saved directly into `backend/uploads`.

Later, this can be replaced with S3, Cloudinary, Supabase Storage, or Firebase Storage. The database can still keep the same `imageUrl` field.
