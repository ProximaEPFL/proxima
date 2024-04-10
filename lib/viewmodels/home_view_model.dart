import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/post_overview.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/services/database/user_repository_service.dart";
import "package:proxima/services/geolocation_service.dart";

/// This viewmodel is used to fetch the list of posts that are displayed in the home feed.
/// It fetches the posts from the database and returns a list of [PostOverview] objects to be displayed.
class HomeViewModel extends AsyncNotifier<List<PostOverview>> {
  HomeViewModel();

  static const kmPostRadius = 0.1;

  @override
  Future<List<PostOverview>> build() async {
    final geoLocationService = ref.watch(geoLocationServiceProvider);
    final postRepository = ref.watch(postRepositoryProvider);
    final userRepository = ref.watch(userRepositoryProvider);

    final position = await geoLocationService.getCurrentPosition();

    final postsFirestore =
        await postRepository.getNearPosts(position, kmPostRadius);

    final postOwnersId =
        postsFirestore.map((post) => post.data.ownerId).toSet();

    final postOwners = await Future.wait(
      postOwnersId.map((userId) => userRepository.getUser(userId)),
    );

    final posts = postsFirestore.map((post) {
      final owner = postOwners.firstWhere(
        (user) => user.uid == post.data.ownerId,
        // This should never be executed in practice as if the owner is not found,
        // the user repository would have already thrown an exception.
        orElse: () => throw Exception("Owner not found"),
      );

      return PostOverview(
        title: post.data.title,
        description: post.data.description,
        voteScore: post.data.voteScore,
        ownerDisplayName: owner.data.displayName,
        commentNumber:
            0, // TODO: Update appropriately when comments are implemented
      );
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

final postOverviewProvider =
    AsyncNotifierProvider<HomeViewModel, List<PostOverview>>(
  () => HomeViewModel(),
);
