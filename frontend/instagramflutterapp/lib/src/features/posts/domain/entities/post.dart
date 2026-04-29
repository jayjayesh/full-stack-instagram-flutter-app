import 'package:equatable/equatable.dart';
import 'package:instagramflutterapp/src/features/auth/domain/entities/user.dart';

class FeedPost extends Equatable {
  final String id;
  final String imageUrl;
  final String? caption;
  final AppUser author;
  final int likeCount;
  final int commentCount;
  final bool likedByMe;
  final bool ownedByMe;
  final DateTime createdAt;

  const FeedPost({
    required this.id,
    required this.imageUrl,
    required this.author,
    required this.likeCount,
    required this.commentCount,
    required this.likedByMe,
    required this.ownedByMe,
    required this.createdAt,
    this.caption,
  });

  FeedPost copyWith({
    int? likeCount,
    int? commentCount,
    bool? likedByMe,
  }) {
    return FeedPost(
      id: id,
      imageUrl: imageUrl,
      caption: caption,
      author: author,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      likedByMe: likedByMe ?? this.likedByMe,
      ownedByMe: ownedByMe,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        imageUrl,
        caption,
        author,
        likeCount,
        commentCount,
        likedByMe,
        ownedByMe,
        createdAt,
      ];
}
