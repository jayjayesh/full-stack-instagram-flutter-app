import 'package:instagramflutterapp/src/features/auth/presentation/providers/session_provider.dart';
import 'package:instagramflutterapp/src/features/posts/domain/entities/comment.dart';
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
  final _editController = TextEditingController();
  bool _isSending = false;
  bool _isSavingEdit = false;
  String? _editingCommentId;

  static const _editCommentAction = 'edit';
  static const _deleteCommentAction = 'delete';

  @override
  void dispose() {
    _controller.dispose();
    _editController.dispose();
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
    final shouldDelete = await _confirmDeleteComment();
    if (!shouldDelete) return;

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

  Future<bool> _confirmDeleteComment() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('posts.delete_comment_title'.tr()),
          content: Text('posts.delete_comment_confirmation'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text('shared.cancel'.tr()),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text('posts.delete_comment_action'.tr()),
            ),
          ],
        );
      },
    );

    return shouldDelete ?? false;
  }

  void _startEditingComment(PostComment comment) {
    setState(() {
      _editingCommentId = comment.id;
      _editController.text = comment.text;
    });
  }

  void _cancelEditingComment() {
    setState(() {
      _editingCommentId = null;
      _isSavingEdit = false;
      _editController.clear();
    });
  }

  Future<void> _saveEditedComment(PostComment comment) async {
    final text = _editController.text.trim();
    if (text.isEmpty || _isSavingEdit) return;

    if (text == comment.text.trim()) {
      _cancelEditingComment();
      return;
    }

    setState(() => _isSavingEdit = true);
    final result = await ref.read(postsRepositoryProvider).updateComment(
          commentId: comment.id,
          text: text,
        );

    if (!mounted) return;

    setState(() => _isSavingEdit = false);

    result.fold(
      (failure) =>
          showToast(context, message: failure.message, status: 'error'),
      (_) {
        _cancelEditingComment();
        ref.invalidate(commentsProvider(widget.postId));
      },
    );
  }

  Future<void> _handleCommentAction(
    String action,
    PostComment comment,
  ) async {
    switch (action) {
      case _editCommentAction:
        _startEditingComment(comment);
        break;
      case _deleteCommentAction:
        await _deleteComment(comment.id);
        break;
    }
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
                      final isOwner = comment.user.id == currentUserId;
                      final isEditing = _editingCommentId == comment.id;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                            child: Text(name.characters.first.toUpperCase())),
                        title: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Padding(
                          padding: EdgeInsets.only(top: AppSpacing.xs),
                          child: isEditing
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppTextField(
                                      controller: _editController,
                                      enabled: !_isSavingEdit,
                                      hint: 'posts.edit_comment_hint'.tr(),
                                      textInputAction: TextInputAction.done,
                                      onFieldSubmitted: (_) =>
                                          _saveEditedComment(comment),
                                    ),
                                    SizedBox(height: AppSpacing.xs),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextButton(
                                          onPressed: _isSavingEdit
                                              ? null
                                              : _cancelEditingComment,
                                          child: Text('shared.cancel'.tr()),
                                        ),
                                        SizedBox(width: AppSpacing.xs),
                                        FilledButton(
                                          onPressed: _isSavingEdit
                                              ? null
                                              : () =>
                                                  _saveEditedComment(comment),
                                          child: _isSavingEdit
                                              ? const SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : Text(
                                                  'posts.save_comment_action'
                                                      .tr(),
                                                ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : Text(comment.text),
                        ),
                        trailing: isOwner && !isEditing
                            ? PopupMenuButton<String>(
                                tooltip: 'Comment actions',
                                onSelected: (value) =>
                                    _handleCommentAction(value, comment),
                                itemBuilder: (context) => [
                                  PopupMenuItem<String>(
                                    value: _editCommentAction,
                                    child: Text(
                                      'posts.edit_comment_action'.tr(),
                                    ),
                                  ),
                                  PopupMenuItem<String>(
                                    value: _deleteCommentAction,
                                    child: Text(
                                      'posts.delete_comment_action'.tr(),
                                    ),
                                  ),
                                ],
                                icon: const Icon(Icons.more_vert),
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
