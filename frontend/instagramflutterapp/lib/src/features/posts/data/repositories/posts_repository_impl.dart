import 'dart:io';

import 'package:dio/dio.dart';
import 'package:instagramflutterapp/src/config/app_config.dart';
import 'package:instagramflutterapp/src/features/posts/data/models/comment_model.dart';
import 'package:instagramflutterapp/src/features/posts/data/models/post_model.dart';
import 'package:instagramflutterapp/src/features/posts/domain/entities/comment.dart';
import 'package:instagramflutterapp/src/features/posts/domain/entities/post.dart';
import 'package:instagramflutterapp/src/features/posts/domain/repositories/posts_repository.dart';
import 'package:instagramflutterapp/src/utils/utils.dart';

class PostsRepositoryImpl implements PostsRepository {
  Dio get _dio => AppConfig.dio;

  @override
  FutureEither<List<FeedPost>> getFeed() {
    return runTask(() async {
      final response = await _dio.get<dynamic>('/posts/feed');
      final data = response.data as Map<String, dynamic>;
      final posts = data['posts'] as List<dynamic>;
      return posts
          .map((post) => FeedPostModel.fromMap(post as Map<String, dynamic>))
          .toList();
    }, requiresNetwork: true);
  }

  @override
  FutureEither<FeedPost> createPost({
    required File photo,
    String? caption,
  }) {
    return runTask(() async {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(photo.path),
        if (caption != null && caption.trim().isNotEmpty)
          'caption': caption.trim(),
      });
      final response = await _dio.post<dynamic>('/posts', data: formData);
      final data = response.data as Map<String, dynamic>;
      return FeedPostModel.fromMap(data['post'] as Map<String, dynamic>);
    }, requiresNetwork: true);
  }

  @override
  FutureEither<void> deletePost(String postId) {
    return runTask(() async {
      await _dio.delete<dynamic>('/posts/$postId');
    }, requiresNetwork: true);
  }

  @override
  FutureEither<FeedPost> likePost(String postId) {
    return _postAction('/posts/$postId/like', isDelete: false);
  }

  @override
  FutureEither<FeedPost> unlikePost(String postId) {
    return _postAction('/posts/$postId/like', isDelete: true);
  }

  @override
  FutureEither<List<PostComment>> getComments(String postId) {
    return runTask(() async {
      final response = await _dio.get<dynamic>('/posts/$postId/comments');
      final data = response.data as Map<String, dynamic>;
      final comments = data['comments'] as List<dynamic>;
      return comments
          .map((comment) =>
              PostCommentModel.fromMap(comment as Map<String, dynamic>))
          .toList();
    }, requiresNetwork: true);
  }

  @override
  FutureEither<PostComment> createComment({
    required String postId,
    required String text,
  }) {
    return runTask(() async {
      final response = await _dio.post<dynamic>(
        '/posts/$postId/comments',
        data: {'text': text},
      );
      final data = response.data as Map<String, dynamic>;
      return PostCommentModel.fromMap(data['comment'] as Map<String, dynamic>);
    }, requiresNetwork: true);
  }

  @override
  FutureEither<void> deleteComment(String commentId) {
    return runTask(() async {
      await _dio.delete<dynamic>('/comments/$commentId');
    }, requiresNetwork: true);
  }

  FutureEither<FeedPost> _postAction(String path, {required bool isDelete}) {
    return runTask(() async {
      final response = isDelete
          ? await _dio.delete<dynamic>(path)
          : await _dio.post<dynamic>(path);
      final data = response.data as Map<String, dynamic>;
      return FeedPostModel.fromMap(data['post'] as Map<String, dynamic>);
    }, requiresNetwork: true);
  }
}
