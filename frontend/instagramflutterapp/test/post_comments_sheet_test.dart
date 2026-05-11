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
import 'package:instagramflutterapp/src/features/posts/presentation/widgets/post_comments_sheet.dart';
import 'package:instagramflutterapp/src/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('Owned comment delete action asks for confirmation first',
      (tester) async {
    final postsRepository = _StubPostsRepository();
    final feedNotifier = _TestFeedNotifier();

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('es')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: ProviderScope(
          overrides: [
            sessionProvider.overrideWith(
              (ref) => _TestSessionNotifier(user: _currentUser),
            ),
            postsRepositoryProvider.overrideWithValue(postsRepository),
            feedProvider.overrideWith((ref) => feedNotifier),
            commentsProvider(_postId).overrideWith((ref) async => [_comment]),
          ],
          child: Builder(
            builder: (context) => MaterialApp(
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
              home: const Scaffold(
                body: PostCommentsSheet(postId: _postId),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Delete comment'));
    await tester.pumpAndSettle();

    expect(find.text('Delete comment?'), findsOneWidget);
    expect(
      find.text('Are you sure you want to delete this comment?'),
      findsOneWidget,
    );

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(postsRepository.deletedCommentIds, isEmpty);
    expect(feedNotifier.decrementedPostIds, isEmpty);

    await tester.tap(find.byTooltip('Delete comment'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Delete comment'));
    await tester.pumpAndSettle();

    expect(postsRepository.deletedCommentIds, ['comment-1']);
    expect(feedNotifier.decrementedPostIds, [_postId]);
  });
}

const _postId = 'post-1';

final _currentUser = AppUser(
  id: 'user-1',
  name: 'Jordan Lee',
  email: 'jordan@example.com',
);

final _comment = PostComment(
  id: 'comment-1',
  text: 'Nice shot',
  user: _currentUser,
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
  _TestFeedNotifier() : super(repository: _StubPostsRepository());

  final List<String> decrementedPostIds = [];

  @override
  void decrementCommentCount(String postId) {
    decrementedPostIds.add(postId);
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
  final List<String> deletedCommentIds = [];

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
    deletedCommentIds.add(commentId);
    return right(null);
  }

  @override
  FutureEither<void> deletePost(String postId) async => right(null);

  @override
  FutureEither<List<FeedPost>> getFeed() async => right(const []);

  @override
  FutureEither<List<PostComment>> getComments(String postId) async =>
      right(const []);

  @override
  FutureEither<FeedPost> likePost(String postId) async {
    throw UnimplementedError();
  }

  @override
  FutureEither<FeedPost> unlikePost(String postId) async {
    throw UnimplementedError();
  }
}
