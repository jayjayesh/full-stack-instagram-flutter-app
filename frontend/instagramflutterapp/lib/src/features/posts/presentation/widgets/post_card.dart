import 'package:instagramflutterapp/src/features/posts/domain/entities/post.dart';
import 'package:instagramflutterapp/src/features/posts/presentation/providers/posts_provider.dart';
import 'package:instagramflutterapp/src/features/posts/presentation/widgets/post_comments_sheet.dart';
import 'package:instagramflutterapp/src/imports/imports.dart';

class PostCard extends ConsumerWidget {
  const PostCard({
    super.key,
    required this.post,
  });

  final FeedPost post;

  String _commentButtonLabel() {
    if (post.commentCount == 0) {
      return 'Leave a comment';
    }

    if (post.commentCount == 1) {
      return 'View 1 comment';
    }

    return 'View ${post.commentCount} comments';
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('posts.delete_post_title'.tr()),
          content: Text('posts.delete_post_confirmation'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text('shared.cancel'.tr()),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text('posts.delete_post_action'.tr()),
            ),
          ],
        );
      },
    );

    return shouldDelete ?? false;
  }

  Future<void> _toggleLike(BuildContext context, WidgetRef ref) async {
    final error = await ref.read(feedProvider.notifier).toggleLike(post);
    if (error != null && context.mounted) {
      showToast(context, message: error, status: 'error');
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final shouldDelete = await _confirmDelete(context);
    if (!shouldDelete) return;

    final error = await ref.read(feedProvider.notifier).deletePost(post.id);
    if (error != null && context.mounted) {
      showToast(context, message: error, status: 'error');
    }
  }

  Future<void> _share(BuildContext context) async {
    final text = [
      post.caption?.trim(),
      post.imageUrl,
    ].where((value) => value != null && value.isNotEmpty).join('\n');

    final result = await ShareService.instance
        .shareText(text, subject: 'Instagram clone photo');
    result.fold(
      (failure) =>
          showToast(context, message: failure.message, status: 'error'),
      (_) {},
    );
  }

  void _openComments(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => PostCommentsSheet(postId: post.id),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final authorName = post.author.name ?? post.author.email;

    return ColoredBox(
      color: cs.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: cs.primaryContainer,
                  child: Text(authorName.characters.first.toUpperCase()),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    authorName,
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (post.ownedByMe)
                  IconButton(
                    tooltip: 'posts.delete_post_action'.tr(),
                    onPressed: () => _delete(context, ref),
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
          ),
          AspectRatio(
            aspectRatio: 1,
            child: AppCachedImage(
              imageUrl: post.imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              useSkeleton: true,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.xs,
              AppSpacing.sm,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: post.likedByMe ? 'Unlike' : 'Like',
                      onPressed: () => _toggleLike(context, ref),
                      icon: Icon(
                        post.likedByMe ? Icons.favorite : Icons.favorite_border,
                        color: post.likedByMe ? Colors.red : null,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Comment',
                      onPressed: () => _openComments(context),
                      icon: const Icon(Icons.mode_comment_outlined),
                    ),
                    IconButton(
                      tooltip: 'Share',
                      onPressed: () => _share(context),
                      icon: const Icon(
                        Icons.share,
                        size: 18,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Text(
                    '${post.likeCount} likes',
                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                if (post.caption != null && post.caption!.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.xs),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: RichText(
                      text: TextSpan(
                        style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                        children: [
                          TextSpan(
                            text: '$authorName ',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(text: post.caption),
                        ],
                      ),
                    ),
                  ),
                ],
                TextButton(
                  onPressed: () => _openComments(context),
                  child: Text(_commentButtonLabel()),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: cs.outlineVariant),
        ],
      ),
    );
  }
}
