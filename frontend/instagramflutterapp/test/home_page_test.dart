import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:instagramflutterapp/src/features/auth/domain/entities/user.dart';
import 'package:instagramflutterapp/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:instagramflutterapp/src/features/auth/presentation/providers/session_provider.dart';
import 'package:instagramflutterapp/src/features/home/presentation/screens/home_page.dart';
import 'package:instagramflutterapp/src/features/posts/domain/entities/comment.dart';
import 'package:instagramflutterapp/src/features/posts/domain/entities/post.dart';
import 'package:instagramflutterapp/src/features/posts/domain/repositories/posts_repository.dart';
import 'package:instagramflutterapp/src/features/posts/presentation/providers/posts_provider.dart';
import 'package:instagramflutterapp/src/routing/app_routes.dart';
import 'package:instagramflutterapp/src/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets(
      'Home page shows the profile summary and handles logout confirmation',
      (tester) async {
    final sessionNotifier = _TestSessionNotifier(
      user: const AppUser(
        id: 'user-1',
        name: 'Jordan Lee',
        email: 'jordan@example.com',
      ),
    );
    final feedNotifier = _TestFeedNotifier(
      state: const FeedState(posts: []),
    );

    await _pumpHomePage(
      tester,
      sessionNotifier: sessionNotifier,
      feedNotifier: feedNotifier,
    );

    expect(find.text('Jordan Lee'), findsOneWidget);
    expect(find.text('@jordan'), findsOneWidget);
    expect(find.text('jordan@example.com'), findsOneWidget);
    expect(find.text('Your activity summary'), findsOneWidget);
    expect(
      find.text('Share your first moment to start building your profile.'),
      findsOneWidget,
    );
    expect(find.text('Posts'), findsOneWidget);
    expect(find.text('Likes'), findsOneWidget);
    expect(find.text('Comments'), findsOneWidget);
    expect(find.text('0'), findsNWidgets(3));

    await tester.tap(find.byType(IconButton, skipOffstage: false).first);
    await tester.pumpAndSettle();

    expect(find.text('Log out?'), findsOneWidget);
    expect(
      find.text('Are you sure you want to log out of your session?'),
      findsOneWidget,
    );

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(sessionNotifier.logoutCallCount, 0);
    expect(find.text('Jordan Lee'), findsOneWidget);

    await tester.tap(find.byType(IconButton, skipOffstage: false).first);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Log out'));
    await tester.pumpAndSettle();

    expect(sessionNotifier.logoutCallCount, 1);
    expect(find.text('Login route'), findsOneWidget);
  });
}

Future<void> _pumpHomePage(
  WidgetTester tester, {
  required _TestSessionNotifier sessionNotifier,
  required _TestFeedNotifier feedNotifier,
}) async {
  final router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (_, __) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const Scaffold(body: Center(child: Text('Login route'))),
      ),
      GoRoute(
        path: AppRoutes.createPost,
        builder: (_, __) =>
            const Scaffold(body: Center(child: Text('Create post route'))),
      ),
    ],
  );

  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('es')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: ProviderScope(
        overrides: [
          sessionProvider.overrideWith((ref) => sessionNotifier),
          feedProvider.overrideWith((ref) => feedNotifier),
        ],
        child: Builder(
          builder: (context) => MaterialApp.router(
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            routerConfig: router,
          ),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

class _TestSessionNotifier extends SessionNotifier {
  _TestSessionNotifier({required AppUser user})
      : super(repository: _StubAuthRepository(initialUser: user)) {
    state = SessionState(
      status: SessionStatus.authenticated,
      user: user,
    );
  }

  int logoutCallCount = 0;

  @override
  Future<void> logout() async {
    logoutCallCount += 1;
    state = const SessionState(status: SessionStatus.unauthenticated);
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
  _StubAuthRepository({required AppUser initialUser}) : _initialUser = initialUser;

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
}

class _StubPostsRepository implements PostsRepository {
  @override
  FutureEither<List<FeedPost>> getFeed() async => right(const []);

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
