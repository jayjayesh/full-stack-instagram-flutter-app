# Frontend Architecture

This Flutter app is feature-first.

Each feature can have:

- `domain`: app entities and repository contracts.
- `data`: API models and repository implementations.
- `presentation`: screens, widgets, and Riverpod providers.

For example, the posts feature has:

- `FeedPost` and `PostComment` entities.
- `PostsRepository` contract.
- `PostsRepositoryImpl` using Dio.
- `feedProvider` for UI state.
- Screens/widgets for upload, feed cards, and comments.
