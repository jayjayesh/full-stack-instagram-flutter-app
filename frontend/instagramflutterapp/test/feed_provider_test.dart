import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:instagramflutterapp/src/features/auth/domain/entities/user.dart';
import 'package:instagramflutterapp/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:instagramflutterapp/src/features/auth/presentation/providers/session_provider.dart';
import 'package:instagramflutterapp/src/features/posts/domain/entities/comment.dart';
import 'package:instagramflutterapp/src/features/posts/domain/entities/post.dart';
import 'package:instagramflutterapp/src/features/posts/domain/repositories/posts_repository.dart';
import 'package:instagramflutterapp/src/features/posts/presentation/providers/posts_provider.dart';
import 'package:instagramflutterapp/src/utils/utils.dart';

void main() {
  test('feedProvider clears cached feed and reloads for the next session user',
      () async {
    final authController = StreamController<AppUser?>.broadcast();
    final authRepository = _FakeAuthRepository(authController.stream);
    final postsRepository = _FakePostsRepository(
      feedResponses: [
        [_post(id: 'post-a', ownerId: 'user-a')],
        [_post(id: 'post-b', ownerId: 'user-b')],
      ],
    );

    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        postsRepositoryProvider.overrideWithValue(postsRepository),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(authController.close);

    final sessionSub = container.listen(sessionProvider, (_, __) {});
    final feedSub =
        container.listen(feedProvider, (_, __) {}, fireImmediately: true);
    addTearDown(sessionSub.close);
    addTearDown(feedSub.close);

    await Future<void>.delayed(Duration.zero);
    expect(postsRepository.getFeedCallCount, 0);
    expect(container.read(feedProvider).posts, isEmpty);

    authController
        .add(const AppUser(id: 'user-a', email: 'user-a@example.com'));
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(postsRepository.getFeedCallCount, 1);
    expect(
      container.read(feedProvider).posts.map((post) => post.id).toList(),
      ['post-a'],
    );

    authController.add(null);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(feedProvider).posts, isEmpty);

    authController
        .add(const AppUser(id: 'user-b', email: 'user-b@example.com'));
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(postsRepository.getFeedCallCount, 2);
    expect(
      container.read(feedProvider).posts.map((post) => post.id).toList(),
      ['post-b'],
    );
  });
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(this._stream);

  final Stream<AppUser?> _stream;

  @override
  Stream<AppUser?> get onAuthStateChanged => _stream;

  @override
  FutureEither<AppUser?> checkAuthState() async => right(null);

  @override
  FutureEither<void> forgotPassword({required String email}) async =>
      right(null);

  @override
  FutureEither<AppUser> login({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }

  @override
  FutureEither<void> logout() async => right(null);

  @override
  FutureEither<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }
}

class _FakePostsRepository implements PostsRepository {
  _FakePostsRepository({required List<List<FeedPost>> feedResponses})
      : _feedResponses = Queue<List<FeedPost>>.from(feedResponses);

  final Queue<List<FeedPost>> _feedResponses;
  int getFeedCallCount = 0;

  @override
  FutureEither<List<FeedPost>> getFeed() async {
    getFeedCallCount += 1;
    return right(_feedResponses.removeFirst());
  }

  @override
  FutureEither<FeedPost> createPost({
    required File photo,
    String? caption,
  }) async {
    throw UnimplementedError();
  }

  @override
  FutureEither<void> deleteComment(String commentId) async {
    throw UnimplementedError();
  }

  @override
  FutureEither<void> deletePost(String postId) async {
    throw UnimplementedError();
  }

  @override
  FutureEither<List<PostComment>> getComments(String postId) async {
    throw UnimplementedError();
  }

  @override
  FutureEither<FeedPost> likePost(String postId) async {
    throw UnimplementedError();
  }

  @override
  FutureEither<FeedPost> unlikePost(String postId) async {
    throw UnimplementedError();
  }

  @override
  FutureEither<PostComment> createComment({
    required String postId,
    required String text,
  }) async {
    throw UnimplementedError();
  }
}

FeedPost _post({required String id, required String ownerId}) {
  return FeedPost(
    id: id,
    imageUrl: 'https://example.com/$id.jpg',
    author: AppUser(id: ownerId, email: '$ownerId@example.com'),
    likeCount: 1,
    commentCount: 1,
    likedByMe: false,
    ownedByMe: true,
    createdAt: DateTime(2026, 1, 1),
  );
}
