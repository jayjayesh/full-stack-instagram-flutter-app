import 'package:instagramflutterapp/src/features/home/presentation/widgets/profile_section_card.dart';
import 'package:instagramflutterapp/src/imports/core_imports.dart';
import 'package:instagramflutterapp/src/imports/packages_imports.dart';
// import 'package:instagramflutterapp/src/features/auth/domain/entities/user.dart';
import 'package:instagramflutterapp/src/features/auth/presentation/providers/session_provider.dart';
import 'package:instagramflutterapp/src/features/posts/presentation/providers/posts_provider.dart';
import 'package:instagramflutterapp/src/features/posts/presentation/widgets/post_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final session = ref.watch(sessionProvider);
    final user = session.user;
    final feed = ref.watch(feedProvider);
    final myPosts = feed.posts.where((post) => post.ownedByMe).toList();
    final totalLikes = myPosts.fold<int>(
      0,
      (sum, post) => sum + post.likeCount,
    );
    final totalComments = myPosts.fold<int>(
      0,
      (sum, post) => sum + post.commentCount,
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppTopBar(
        title: 'Feed',
        showBackButton: false,
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: () async {
              await ref.read(sessionProvider.notifier).logout();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.createPost),
        child: const Icon(Icons.add_a_photo_outlined),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(feedProvider.notifier).loadFeed(),
          child: Builder(
            builder: (context) {
              final profileSection = ProfileSection(
                user: user,
                postCount: myPosts.length,
                totalLikes: totalLikes,
                totalComments: totalComments,
              );

              if (feed.isLoading && feed.posts.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (feed.error != null && feed.posts.isEmpty) {
                return ListView(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  children: [
                    profileSection,
                    SizedBox(height: AppSpacing.xl),
                    Icon(Icons.cloud_off_outlined,
                        size: 56, color: colorScheme.error),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      feed.error!,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge,
                    ),
                    SizedBox(height: AppSpacing.md),
                    FilledButton.icon(
                      onPressed: () =>
                          ref.read(feedProvider.notifier).loadFeed(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try again'),
                    ),
                  ],
                );
              }

              if (feed.posts.isEmpty) {
                return ListView(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  children: [
                    profileSection,
                    SizedBox(height: AppSpacing.xxxl),
                    SizedBox(height: AppSpacing.xxxl),
                    Icon(
                      Icons.photo_camera_back_outlined,
                      size: 64,
                      color: colorScheme.primary,
                    ),
                    SizedBox(height: AppSpacing.lg),
                    Text(
                      'Welcome ${user?.name ?? user?.email ?? ''}',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Upload your first photo to start the feed.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    FilledButton.icon(
                      onPressed: () => context.push(AppRoutes.createPost),
                      icon: const Icon(Icons.add_a_photo_outlined),
                      label: const Text('Upload photo'),
                    ),
                  ],
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(AppSpacing.md),
                itemCount: feed.posts.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.md),
                      child: profileSection,
                    );
                  }

                  return Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                    child: PostCard(post: feed.posts[index - 1]),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
