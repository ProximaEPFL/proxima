import "package:collection/collection.dart";
import "package:geoflutterfire_plus/geoflutterfire_plus.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/ui/post_overview.dart";
import "package:proxima/services/database/challenge_repository_service.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/services/database/user_repository_service.dart";
import "package:proxima/services/geolocation_service.dart";
import "package:proxima/services/sorting/post_sorting_service.dart";
import "package:proxima/viewmodels/feed_sort_options_view_model.dart";
import "package:proxima/viewmodels/login_view_model.dart";

/// This viewmodel is used to fetch the list of posts that are displayed in the home feed.
/// It fetches the posts from the database and returns a list of
/// (postId: [PostIdFirestore], postOverview: [PostOverview]) objects to be displayed.
/// These represent the overview data to be displayed associated to the corresponding post id.
/// Note: this viewmodel also provides the data for the post page
class HomeViewModel extends AutoDisposeAsyncNotifier<List<PostOverview>> {
  HomeViewModel();

  static const kmPostRadius = 0.1;

  @override
  Future<List<PostOverview>> build() async {
    final geoLocationService = ref.watch(geoLocationServiceProvider);
    final postRepository = ref.watch(postRepositoryProvider);
    final userRepository = ref.watch(userRepositoryProvider);
    final challengeRepositoryService = ref.watch(
      challengeRepositoryServiceProvider,
    );

    final postSortingService = ref.watch(postSortingServiceProvider);
    final sortOption = ref.watch(feedSortOptionsProvider);

    final position = await geoLocationService.getCurrentPosition();

    List<PostFirestore> postsFirestore = await postRepository.getNearPosts(
      position,
      kmPostRadius,
    );

    final challenges = await challengeRepositoryService.getChallenges(
      ref.read(uidProvider)!,
      position,
    );
    final uncompletedChallenges = challenges.whereNot(
      (challenge) => challenge.data.isCompleted,
    );
    final uncompletedChallengesId = uncompletedChallenges.map(
      (challenge) => challenge.postId,
    );

    postsFirestore = postSortingService.sort(
      postsFirestore,
      sortOption,
      position,
      putOnTop: uncompletedChallengesId.toSet(),
    );

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
      final distance = (GeoFirePoint(position)
                  .distanceBetweenInKm(geopoint: post.location.geoPoint) *
              1000)
          .round(); //TODO: create method because used here and in challenges (+tests)

      final postOverview = PostOverview(
        postId: post.id,
        title: post.data.title,
        description: post.data.description,
        voteScore: post.data.voteScore,
        ownerDisplayName: owner.data.displayName,
        commentNumber: 0,
        // TODO: Update appropriately when comments are implemented
        publicationDate: post.data.publicationTime.toDate(),
        distance: distance,
        isChallenge: uncompletedChallengesId.contains(post.id),
      );

      return postOverview;
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
    AutoDisposeAsyncNotifierProvider<HomeViewModel, List<PostOverview>>(
  () => HomeViewModel(),
);
