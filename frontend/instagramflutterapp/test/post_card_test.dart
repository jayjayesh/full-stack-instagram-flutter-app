import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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
import 'package:instagramflutterapp/src/features/posts/presentation/widgets/post_card.dart';
import 'package:instagramflutterapp/src/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('Owned post delete action asks for confirmation first',
      (tester) async {
    final feedNotifier = _TestFeedNotifier(
      state: FeedState(posts: [_ownedPost]),
    );

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('es')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: ProviderScope(
          overrides: [
            sessionProvider.overrideWith(
              (ref) => _TestSessionNotifier(user: _ownedPost.author),
            ),
            feedProvider.overrideWith((ref) => feedNotifier),
          ],
          child: Builder(
            builder: (context) => MaterialApp(
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
              home: Scaffold(
                body: SingleChildScrollView(
                  child: PostCard(post: _ownedPost),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    await tester.tap(find.byTooltip('Delete post'));
    await tester.pump();

    expect(find.text('Delete post?'), findsOneWidget);
    expect(
      find.text('Are you sure you want to delete this post?'),
      findsOneWidget,
    );

    await tester.tap(find.text('Cancel'));
    await tester.pump();

    expect(feedNotifier.deletedPostIds, isEmpty);

    await tester.tap(find.byTooltip('Delete post'));
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, 'Delete post'));
    await tester.pump();

    expect(feedNotifier.deletedPostIds, ['post-1']);
  });
}

final _ownedPost = FeedPost(
  id: 'post-1',
  imageUrl: 'https://example.com/photo.jpg',
  caption: 'Sunset walk',
  author: AppUser(
    id: 'user-1',
    name: 'Jordan Lee',
    email: 'jordan@example.com',
  ),
  likeCount: 4,
  commentCount: 2,
  likedByMe: false,
  ownedByMe: true,
  createdAt: DateTime(2026, 5, 6),
);

class _TestSessionNotifier extends SessionNotifier {
  _TestSessionNotifier({required AppUser user})
      : super(repository: _StubAuthRepository(initialUser: user)) {
    state = SessionState(
      status: SessionStatus.authenticated,
      user: user,
    );
  }
}

class _TestFeedNotifier extends FeedNotifier {
  _TestFeedNotifier({required FeedState state})
      : super(repository: _StubPostsRepository()) {
    this.state = state;
  }

  final List<String> deletedPostIds = [];

  @override
  Future<String?> deletePost(String postId) async {
    deletedPostIds.add(postId);
    state = state.copyWith(
      posts: state.posts.where((post) => post.id != postId).toList(),
    );
    return null;
  }

  @override
  Future<void> loadFeed() async {}
}

class _StubAuthRepository implements AuthRepository {
  _StubAuthRepository({required AppUser initialUser})
      : _initialUser = initialUser;

  final AppUser _initialUser;

  @override
  Stream<AppUser?> get onAuthStateChanged => const Stream<AppUser?>.empty();

  @override
  FutureEither<AppUser?> checkAuthState() async => right(_initialUser);

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

  @override
  FutureEither<AppUser> updateProfile({
    required String name,
    File? photo,
  }) async {
    throw UnimplementedError();
  }
}

class _StubPostsRepository implements PostsRepository {
  @override
  FutureEither<PostComment> createComment({
    required String postId,
    required String text,
  }) async {
    throw UnimplementedError();
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
  FutureEither<void> deletePost(String postId) async => right(null);

  @override
  FutureEither<List<FeedPost>> getFeed() async => right(const []);

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
}
