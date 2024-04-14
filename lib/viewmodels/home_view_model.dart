import "dart:async";

import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/post_overview.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/services/database/user_repository_service.dart";
import "package:proxima/services/geolocation_service.dart";

/// This viewmodel is used to fetch the list of posts that are displayed in the home feed.
/// It fetches the posts from the database and returns a list of [PostOverview] objects to be displayed.
/// The viewmodel is a [StreamNotifier] which means that it will emit the list of posts to the UI
/// whenever the list of posts is updated.
/// Concretely, if the relevent posts in the database change, the viewmodel will emit a new list of posts
/// (this also applies to when posts are added or removed from the database).
///
/// /!\ If the location of the user changes however, the refresh method must be
/// called to update the list of nearby posts to the new location. /!\
class HomeViewModel extends AutoDisposeStreamNotifier<List<PostOverview>> {
  HomeViewModel();

  static const kmPostRadius = 0.1;

  /// Builds the stream of posts that will be displayed in the home feed
  @override
  Stream<List<PostOverview>> build() async* {
    final geoLocationService = ref.watch(geoLocationServiceProvider);
    final postRepository = ref.watch(postRepositoryProvider);
    final userRepository = ref.watch(userRepositoryProvider);

    final position = await geoLocationService.getCurrentPosition();

    final postsFirestoreStream =
        postRepository.getNearPosts(position, kmPostRadius);

    final futurePostOverviewsStream =
        postsFirestoreStream.map((postList) async {
      final postOwnersId = postList.map((post) => post.data.ownerId).toSet();

      final postOwners = await Future.wait(
        postOwnersId.map((userId) => userRepository.getUser(userId)),
      );

      final posts = postList.map((post) {
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
    });

    await for (final futurePostOverviews in futurePostOverviewsStream) {
      yield await futurePostOverviews;
    }
  }

  /// Refreshes the list of posts to display the posts that are near the new location of the user
  /// This method should be called whenever the location of the user changes.
  void refresh() {
    state = const AsyncLoading();
    ref.invalidateSelf();
  }
}

final postOverviewProvider =
    AutoDisposeStreamNotifierProvider<HomeViewModel, List<PostOverview>>(
  () => HomeViewModel(),
);
