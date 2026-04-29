import 'package:instagramflutterapp/src/features/auth/domain/entities/user.dart';
import 'package:instagramflutterapp/src/features/posts/domain/entities/comment.dart';

class PostCommentModel extends PostComment {
  const PostCommentModel({
    required super.id,
    required super.text,
    required super.user,
    required super.createdAt,
  });

  factory PostCommentModel.fromMap(Map<String, dynamic> map) {
    final user = map['user'] as Map<String, dynamic>;

    return PostCommentModel(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      user: AppUser(
        id: user['id'] ?? '',
        email: user['email'] ?? '',
        name: user['name'],
        photoUrl: user['photoUrl'],
      ),
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
