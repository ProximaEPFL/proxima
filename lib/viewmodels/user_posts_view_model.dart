import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/user_post.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/utils/ui/circular_value.dart";
import "package:proxima/viewmodels/login_view_model.dart";

typedef UserPostsState = List<UserPost>;

/// Provides a refreshable async list of posts for the currently logged in user.
/// Built for the profile page to display all posts a user made and potentially
/// delete them as requested.
class UserPostsViewModel extends AsyncNotifier<UserPostsState> {
  UserPostsViewModel();

  @override
  Future<UserPostsState> build() async {
    final postRepository = ref.watch(postRepositoryProvider);
    final user = ref.watch(uidProvider);

    if (user == null) {
      return Future.error(
        "${CircularValue.debugErrorTag} User must be logged in before displaying the home page.",
      );
    }

    final postsFirestore = await postRepository.getUserPosts(user);
    final posts = postsFirestore.map((post) {
      final userPost = UserPost(
        postId: post.id,
        title: post.data.title,
        description: post.data.description,
      );

      return userPost;
    }).toList();

    return posts;
  }

  /// Refresh the list of posts
  /// This will put the state of the viewmodel to loading, fetch the posts
  /// and update the state accordingly
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

final userPostsProvider =
    AsyncNotifierProvider<UserPostsViewModel, UserPostsState>(
  () => UserPostsViewModel(),
);
