import "package:collection/collection.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/ui/user_post_details.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";
import "package:proxima/viewmodels/posts_feed_view_model.dart";

typedef UserPostsState = List<UserPostDetails>;

/// Provides a refreshable async list of posts for the currently logged in user.
/// Built for the profile page to display all posts a user made and potentially
/// delete them as requested.
class UserPostsViewModel extends AutoDisposeAsyncNotifier<UserPostsState> {
  UserPostsViewModel();

  @override
  Future<UserPostsState> build() async {
    final postRepository = ref.watch(postRepositoryServiceProvider);
    final user = ref.watch(validLoggedInUserIdProvider);

    final postsFirestore = await postRepository.getUserPosts(user);

    // Sort the posts by publication time from lattest to oldest
    final sortedPostsFirestore = postsFirestore.toList().sorted(
          (postA, postB) =>
              postB.data.publicationTime.compareTo(postA.data.publicationTime),
        );

    final posts = sortedPostsFirestore.map((post) {
      final userPost = UserPostDetails(
        postId: post.id,
        title: post.data.title,
        description: post.data.description,
      );

      return userPost;
    }).toList();

    return posts;
  }

  /// Delete the post with the given [postId] from the database
  /// and refresh the state of this viewmodel (list of user posts).
  Future<void> deletePost(PostIdFirestore postId) async {
    final postRepository = ref.watch(postRepositoryServiceProvider);
    await postRepository.deletePost(postId);

    // Not awaited, will show loading for user (faster user feedback)
    refresh();
    // Refresh the home feed after post deletion
    ref.read(postsFeedViewModelProvider.notifier).refresh();
  }

  /// Refresh the list of posts
  /// This will put the state of the viewmodel to loading, fetch the posts
  /// and update the state accordingly
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

final userPostsViewModelProvider =
    AutoDisposeAsyncNotifierProvider<UserPostsViewModel, UserPostsState>(
  () => UserPostsViewModel(),
);
