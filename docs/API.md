# API Reference

Base API URL: `/api`

## Auth

### `POST /auth/signup`

Body:

```json
{
  "name": "Student",
  "email": "student@example.com",
  "password": "password123"
}
```

### `POST /auth/login`

Body:

```json
{
  "email": "student@example.com",
  "password": "password123"
}
```

### `GET /auth/me`

Requires:

```text
Authorization: Bearer <token>
```

## Posts

### `POST /posts`

Requires auth and multipart form data:

- `photo`: image file
- `caption`: optional text

### `GET /posts/feed`

Returns posts with author, like count, comment count, and whether the current user liked each post.

### `DELETE /posts/:id`

Only the owner can delete a post.

## Likes

### `POST /posts/:id/like`

Likes a post.

### `DELETE /posts/:id/like`

Unlikes a post.

## Comments

### `GET /posts/:id/comments`

Returns comments for one post.

### `POST /posts/:id/comments`

Body:

```json
{
  "text": "Nice photo!"
}
```

### `DELETE /comments/:id`

Only the owner can delete a comment.
