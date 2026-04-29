# Frontend Guide

The frontend lives in `frontend/instagramflutterapp/` and uses Flutter, Riverpod, GoRouter, and Dio.

The most important frontend areas are:

- `lib/src/services/auth_service.dart`: login/signup/logout API calls.
- `lib/src/config/app_config.dart`: Dio setup and JWT header.
- `lib/src/features/posts`: feed, upload, likes, comments, and share.
- `lib/src/features/home/presentation/screens/home_page.dart`: the main photo feed.
