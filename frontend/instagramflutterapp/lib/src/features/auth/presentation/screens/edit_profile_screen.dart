import 'dart:io';

import 'package:instagramflutterapp/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:instagramflutterapp/src/features/auth/presentation/providers/session_provider.dart';
import 'package:instagramflutterapp/src/features/posts/presentation/providers/posts_provider.dart';
import 'package:instagramflutterapp/src/imports/imports.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final String _initialName;
  final _formKey = GlobalKey<FormState>();
  File? _selectedPhoto;

  @override
  void initState() {
    super.initState();
    final currentUser = ref.read(sessionProvider).user;
    _initialName = currentUser?.name?.trim() ?? '';
    _nameController = TextEditingController(text: _initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final result = await MediaService.instance.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );

    if (!mounted) return;

    result.fold(
      (failure) =>
          showToast(context, message: failure.message, status: 'error'),
      (file) {
        if (file == null) return;
        setState(() => _selectedPhoto = file);
      },
    );
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final trimmedName = _nameController.text.trim();
    final hasChanges = trimmedName != _initialName || _selectedPhoto != null;

    if (!hasChanges) {
      showToast(
        context,
        message: 'auth.profile_no_changes'.tr(),
        status: 'warning',
      );
      return;
    }

    final result =
        await ref.read(authControllerProvider.notifier).updateProfile(
              name: trimmedName,
              photo: _selectedPhoto,
            );

    if (!mounted) return;

    result.fold(
      (failure) =>
          showToast(context, message: failure.message, status: 'error'),
      (_) async {
        await ref.read(feedProvider.notifier).loadFeed();
        if (!mounted) return;
        context.pop();
        showGlobalToast(
          message: 'auth.profile_updated'.tr(),
          status: 'success',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionProvider).user;
    final isSaving = ref.watch(authControllerProvider);
    final theme = context.theme;
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final displayName = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : (user?.name?.trim().isNotEmpty ?? false)
            ? user!.name!.trim()
            : 'Creator';
    final handle = user?.email.split('@').first ?? 'guest';

    ImageProvider<Object>? imageProvider;
    if (_selectedPhoto != null) {
      imageProvider = FileImage(_selectedPhoto!);
    } else if (user?.photoUrl?.isNotEmpty ?? false) {
      imageProvider = NetworkImage(user!.photoUrl!);
    }

    return Scaffold(
      appBar: AppTopBar(title: 'auth.edit_profile'.tr()),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.lg),
          children: [
            Center(
              child: Column(
                children: [
                  InkWell(
                    onTap: isSaving ? null : _pickPhoto,
                    borderRadius: BorderRadius.circular(56),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 52,
                          backgroundColor: colorScheme.primaryContainer,
                          backgroundImage: imageProvider,
                          child: imageProvider == null
                              ? Text(
                                  displayName.characters.first.toUpperCase(),
                                  style: textTheme.headlineMedium?.copyWith(
                                    color: colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorScheme.surface,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.shadow.withValues(
                                    alpha: 0.12,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    '@$handle',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    user?.email ?? 'No email available',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            Form(
              key: _formKey,
              child: AppTextField(
                controller: _nameController,
                enabled: !isSaving,
                label: 'auth.display_name'.tr(),
                prefixIcon: const Icon(Icons.person_outline),
                validator: (value) {
                  if (AppUtils.isBlank(value?.trim())) {
                    return 'auth.name_required'.tr();
                  }
                  if ((value?.trim().length ?? 0) > 80) {
                    return 'auth.name_too_long'.tr();
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'auth.display_name_hint'.tr(),
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: isSaving ? null : _saveProfile,
              icon: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text('auth.save_profile'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
