import 'dart:io';

import 'package:instagramflutterapp/src/features/posts/data/repositories/posts_repository_impl.dart';
import 'package:instagramflutterapp/src/features/posts/domain/entities/comment.dart';
import 'package:instagramflutterapp/src/features/posts/domain/entities/post.dart';
import 'package:instagramflutterapp/src/features/posts/domain/repositories/posts_repository.dart';
import 'package:instagramflutterapp/src/imports/packages_imports.dart';

final postsRepositoryProvider = Provider<PostsRepository>((ref) {
  return PostsRepositoryImpl();
});

final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  return FeedNotifier(repository: ref.read(postsRepositoryProvider))
    ..loadFeed();
});

final commentsProvider =
    FutureProvider.family<List<PostComment>, String>((ref, postId) async {
  final result = await ref.read(postsRepositoryProvider).getComments(postId);
  return result.fold((failure) => throw failure, (comments) => comments);
});

class FeedState {
  final List<FeedPost> posts;
  final bool isLoading;
  final String? error;

  const FeedState({
    this.posts = const [],
    this.isLoading = false,
    this.error,
  });

  FeedState copyWith({
    List<FeedPost>? posts,
    bool? isLoading,
    String? error,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class FeedNotifier extends StateNotifier<FeedState> {
  FeedNotifier({required PostsRepository repository})
      : _repository = repository,
        super(const FeedState());

  final PostsRepository _repository;

  Future<void> loadFeed() async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.getFeed();
    state = result.fold(
      (failure) => state.copyWith(isLoading: false, error: failure.message),
      (posts) => FeedState(posts: posts),
    );
  }

  Future<String?> createPost({
    required File photo,
    String? caption,
  }) async {
    final result = await _repository.createPost(photo: photo, caption: caption);
    return result.fold(
      (failure) => failure.message,
      (post) {
        state = state.copyWith(posts: [post, ...state.posts]);
        return null;
      },
    );
  }

  Future<String?> deletePost(String postId) async {
    final previousPosts = state.posts;
    state = state.copyWith(
      posts: state.posts.where((post) => post.id != postId).toList(),
    );

    final result = await _repository.deletePost(postId);
    return result.fold(
      (failure) {
        state = state.copyWith(posts: previousPosts);
        return failure.message;
      },
      (_) => null,
    );
  }

  Future<String?> toggleLike(FeedPost post) async {
    final previousPosts = state.posts;
    final optimisticPost = post.copyWith(
      likedByMe: !post.likedByMe,
      likeCount: post.likedByMe ? post.likeCount - 1 : post.likeCount + 1,
    );

    _replacePost(optimisticPost);

    final result = post.likedByMe
        ? await _repository.unlikePost(post.id)
        : await _repository.likePost(post.id);

    return result.fold(
      (failure) {
        state = state.copyWith(posts: previousPosts);
        return failure.message;
      },
      (freshPost) {
        _replacePost(freshPost);
        return null;
      },
    );
  }

  void incrementCommentCount(String postId) {
    state = state.copyWith(
      posts: state.posts.map((post) {
        if (post.id != postId) return post;
        return post.copyWith(commentCount: post.commentCount + 1);
      }).toList(),
    );
  }

  void decrementCommentCount(String postId) {
    state = state.copyWith(
      posts: state.posts.map((post) {
        if (post.id != postId) return post;
        final nextCount = post.commentCount > 0 ? post.commentCount - 1 : 0;
        return post.copyWith(commentCount: nextCount);
      }).toList(),
    );
  }

  void _replacePost(FeedPost replacement) {
    state = state.copyWith(
      posts: state.posts.map((post) {
        return post.id == replacement.id ? replacement : post;
      }).toList(),
    );
  }
}
