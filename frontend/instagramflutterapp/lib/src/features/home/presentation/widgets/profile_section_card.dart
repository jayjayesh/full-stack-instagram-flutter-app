import 'package:flutter/material.dart';
import 'package:instagramflutterapp/src/features/auth/domain/entities/user.dart';
import 'package:instagramflutterapp/src/features/home/presentation/widgets/profile_stat_card.dart';
import 'package:instagramflutterapp/src/shared/shared.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({
    super.key,
    required this.user,
    required this.postCount,
    required this.totalLikes,
    required this.totalComments,
    required this.onEditProfile,
  });

  final AppUser? user;
  final int postCount;
  final int totalLikes;
  final int totalComments;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final displayName = (user?.name?.trim().isNotEmpty ?? false)
        ? user!.name!.trim()
        : 'Creator';
    final handle = user?.email.split('@').first ?? 'guest';
    final hasPhoto = user?.photoUrl?.isNotEmpty ?? false;

    return AppCard(
      showShadow: true,
      color: colorScheme.surfaceContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: colorScheme.primaryContainer,
                backgroundImage:
                    hasPhoto ? NetworkImage(user!.photoUrl!) : null,
                child: hasPhoto
                    ? null
                    : Text(
                        displayName.characters.first.toUpperCase(),
                        style: textTheme.titleLarge?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      '@$handle',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      user?.email ?? 'No email available',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: onEditProfile,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'Your activity',
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            postCount == 0
                ? 'Share your first moment to start building your profile.'
                : 'Your activity snapshot updates as you post and engage with the feed.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: ProfileStat(
                  label: 'Posts',
                  value: postCount.toString(),
                  icon: Icons.grid_view_rounded,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ProfileStat(
                  label: 'Likes',
                  value: totalLikes.toString(),
                  icon: Icons.favorite_border_rounded,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ProfileStat(
                  label: 'Comments',
                  value: totalComments.toString(),
                  icon: Icons.mode_comment_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
