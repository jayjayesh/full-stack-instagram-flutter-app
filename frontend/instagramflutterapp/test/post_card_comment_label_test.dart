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

  testWidgets('Zero comment count shows leave a comment CTA', (tester) async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('es')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: ProviderScope(
          overrides: [
            sessionProvider.overrideWith(
              (ref) => _TestSessionNotifier(user: _zeroCommentPost.author),
            ),
            feedProvider.overrideWith(
              (ref) => _TestFeedNotifier(
                state: FeedState(posts: [_zeroCommentPost]),
              ),
            ),
          ],
          child: Builder(
            builder: (context) => MaterialApp(
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
              home: Scaffold(
                body: SingleChildScrollView(
                  child: PostCard(post: _zeroCommentPost),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final allText =
        tester.allWidgets.whereType<Text>().map((text) => text.data).toList();

    expect(allText, contains('Leave a comment'));
    expect(allText, isNot(contains('View 0 comments')));
  });
}

final _zeroCommentPost = FeedPost(
  id: 'post-2',
  imageUrl: 'https://example.com/food.jpg',
  caption: 'Gujarati thali preparation',
  author: const AppUser(
    id: 'user-2',
    name: 'Student',
    email: 'student@example.com',
  ),
  likeCount: 2,
  commentCount: 0,
  likedByMe: false,
  ownedByMe: false,
  createdAt: DateTime(2026, 5, 11),
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
