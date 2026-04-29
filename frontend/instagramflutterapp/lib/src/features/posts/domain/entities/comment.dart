import 'package:equatable/equatable.dart';
import 'package:instagramflutterapp/src/features/auth/domain/entities/user.dart';

class PostComment extends Equatable {
  final String id;
  final String text;
  final AppUser user;
  final DateTime createdAt;

  const PostComment({
    required this.id,
    required this.text,
    required this.user,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, text, user, createdAt];
}
