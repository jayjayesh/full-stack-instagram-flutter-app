import 'dart:io';

import 'package:instagramflutterapp/src/features/posts/domain/entities/comment.dart';
import 'package:instagramflutterapp/src/features/posts/domain/entities/post.dart';
import 'package:instagramflutterapp/src/utils/utils.dart';

abstract class PostsRepository {
  FutureEither<List<FeedPost>> getFeed();

  FutureEither<FeedPost> createPost({
    required File photo,
    String? caption,
  });

  FutureEither<void> deletePost(String postId);

  FutureEither<FeedPost> likePost(String postId);

  FutureEither<FeedPost> unlikePost(String postId);

  FutureEither<List<PostComment>> getComments(String postId);

  FutureEither<PostComment> createComment({
    required String postId,
    required String text,
  });

  FutureEither<void> deleteComment(String commentId);
}
