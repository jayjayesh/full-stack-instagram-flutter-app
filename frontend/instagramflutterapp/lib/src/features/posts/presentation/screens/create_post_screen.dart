import 'dart:io';

import 'package:instagramflutterapp/src/features/posts/presentation/providers/posts_provider.dart';
import 'package:instagramflutterapp/src/imports/imports.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _captionController = TextEditingController();
  File? _photo;
  bool _isSaving = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final result = await MediaService.instance.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1400,
    );

    result.fold(
      (failure) =>
          showToast(context, message: failure.message, status: 'error'),
      (file) {
        if (file != null) {
          setState(() => _photo = file);
        }
      },
    );
  }

  Future<void> _createPost() async {
    final photo = _photo;
    if (photo == null) {
      showToast(context, message: 'Choose a photo first.', status: 'warning');
      return;
    }

    setState(() => _isSaving = true);
    final error = await ref.read(feedProvider.notifier).createPost(
          photo: photo,
          caption: _captionController.text,
        );
    setState(() => _isSaving = false);

    if (!mounted) return;
    if (error != null) {
      showToast(context, message: error, status: 'error');
      return;
    }

    Navigator.pop(context);
    showToast(context, message: 'Photo posted.', status: 'success');
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;

    return Scaffold(
      appBar: const AppTopBar(title: 'New photo'),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.lg),
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: InkWell(
                onTap: _isSaving ? null : _pickPhoto,
                borderRadius: BorderRadius.circular(8),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: _photo == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                size: 48, color: cs.primary),
                            SizedBox(height: AppSpacing.sm),
                            Text('Choose photo',
                                style: context.theme.textTheme.titleMedium),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_photo!, fit: BoxFit.cover),
                        ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _captionController,
              enabled: !_isSaving,
              label: 'Caption',
              maxLines: 4,
              prefixIcon: const Icon(Icons.short_text),
            ),
            SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: _isSaving ? null : _createPost,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_upload_outlined),
              label: const Text('Post photo'),
            ),
          ],
        ),
      ),
    );
  }
}
