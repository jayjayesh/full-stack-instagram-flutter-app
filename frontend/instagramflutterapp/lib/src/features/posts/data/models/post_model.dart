import 'package:instagramflutterapp/src/features/auth/domain/entities/user.dart';
import 'package:instagramflutterapp/src/features/posts/domain/entities/post.dart';

class FeedPostModel extends FeedPost {
  const FeedPostModel({
    required super.id,
    required super.imageUrl,
    required super.author,
    required super.likeCount,
    required super.commentCount,
    required super.likedByMe,
    required super.ownedByMe,
    required super.createdAt,
    super.caption,
  });

  factory FeedPostModel.fromMap(Map<String, dynamic> map) {
    final author = map['author'] as Map<String, dynamic>;

    return FeedPostModel(
      id: map['id'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      caption: map['caption'],
      author: AppUser(
        id: author['id'] ?? '',
        email: author['email'] ?? '',
        name: author['name'],
        photoUrl: author['photoUrl'],
      ),
      likeCount: map['likeCount'] ?? 0,
      commentCount: map['commentCount'] ?? 0,
      likedByMe: map['likedByMe'] ?? false,
      ownedByMe: map['ownedByMe'] ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
