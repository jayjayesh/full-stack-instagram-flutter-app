import 'package:instagramflutterapp/src/features/auth/presentation/providers/session_provider.dart';
import 'package:instagramflutterapp/src/features/posts/presentation/providers/posts_provider.dart';
import 'package:instagramflutterapp/src/imports/imports.dart';

class PostCommentsSheet extends ConsumerStatefulWidget {
  const PostCommentsSheet({
    super.key,
    required this.postId,
  });

  final String postId;

  @override
  ConsumerState<PostCommentsSheet> createState() => _PostCommentsSheetState();
}

class _PostCommentsSheetState extends ConsumerState<PostCommentsSheet> {
  final _controller = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    final result = await ref.read(postsRepositoryProvider).createComment(
          postId: widget.postId,
          text: text,
        );
    setState(() => _isSending = false);

    result.fold(
      (failure) =>
          showToast(context, message: failure.message, status: 'error'),
      (_) {
        _controller.clear();
        ref.invalidate(commentsProvider(widget.postId));
        ref.read(feedProvider.notifier).incrementCommentCount(widget.postId);
      },
    );
  }

  Future<void> _deleteComment(String commentId) async {
    final result =
        await ref.read(postsRepositoryProvider).deleteComment(commentId);
    result.fold(
      (failure) =>
          showToast(context, message: failure.message, status: 'error'),
      (_) {
        ref.invalidate(commentsProvider(widget.postId));
        ref.read(feedProvider.notifier).decrementCommentCount(widget.postId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(commentsProvider(widget.postId));
    final currentUserId = ref.watch(sessionProvider).user?.id;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text(
                'Comments',
                style: context.theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: comments.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text(error.toString())),
                data: (items) {
                  if (items.isEmpty) {
                    return const Center(child: Text('No comments yet.'));
                  }

                  return ListView.separated(
                    padding: EdgeInsets.all(AppSpacing.md),
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final comment = items[index];
                      final name = comment.user.name ?? comment.user.email;
                      final canDelete = comment.user.id == currentUserId;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                            child: Text(name.characters.first.toUpperCase())),
                        title: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(comment.text),
                        trailing: canDelete
                            ? IconButton(
                                tooltip: 'Delete comment',
                                onPressed: () => _deleteComment(comment.id),
                                icon: const Icon(Icons.delete_outline),
                              )
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _controller,
                      enabled: !_isSending,
                      hint: 'Add a comment',
                      textInputAction: TextInputAction.send,
                      onFieldSubmitted: (_) => _send(),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  IconButton.filled(
                    tooltip: 'Send comment',
                    onPressed: _isSending ? null : _send,
                    icon: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
