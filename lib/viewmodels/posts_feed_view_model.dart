import "package:collection/collection.dart";
import "package:geoflutterfire_plus/geoflutterfire_plus.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/challenge/challenge_firestore.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/ui/post_details.dart";
import "package:proxima/services/database/challenge_repository_service.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/services/database/user_repository_service.dart";
import "package:proxima/services/sensors/geolocation_service.dart";
import "package:proxima/services/sorting/post/post_sorting_service.dart";
import "package:proxima/viewmodels/feed_sort_options_view_model.dart";
import "package:proxima/viewmodels/login_view_model.dart";

/// This viewmodel is used to fetch the list of posts that are displayed in the home feed.
/// It fetches the posts from the database and returns a list of
/// (postId: [PostIdFirestore], postDetails: [PostDetails]) objects to be displayed.
/// These represent the overview data to be displayed associated to the corresponding post id.
/// Note: this viewmodel also provides the data for the post page
class PostsFeedViewModel extends AutoDisposeAsyncNotifier<List<PostDetails>> {
  PostsFeedViewModel();

  static const kmPostRadius = 0.1;

  @override
  Future<List<PostDetails>> build() async {
    final geoLocationService = ref.watch(geolocationServiceProvider);
    final postRepository = ref.watch(postRepositoryServiceProvider);
    final userRepository = ref.watch(userRepositoryServiceProvider);
    final challengeRepositoryService = ref.watch(
      challengeRepositoryServiceProvider,
    );

    final postSortingService = ref.watch(postSortingServiceProvider);
    final sortOption = ref.watch(feedSortOptionsViewModelProvider);

    final position = await geoLocationService.getCurrentPosition();

    final postsFirestoreFuture = postRepository.getNearPosts(
      position,
      kmPostRadius,
    );
    final challengesFuture = challengeRepositoryService.getChallenges(
      ref.read(loggedInUserIdProvider)!,
      position,
    );

    final results = await Future.wait([
      postsFirestoreFuture,
      challengesFuture,
    ]);
    List<PostFirestore> postsFirestore = results[0] as List<PostFirestore>;
    final List<ChallengeFirestore> challenges =
        results[1] as List<ChallengeFirestore>;

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

      final postDetails = PostDetails(
        postId: post.id,
        title: post.data.title,
        description: post.data.description,
        voteScore: post.data.voteScore,
        ownerDisplayName: owner.data.displayName,
        commentNumber: post.data.commentCount,
        publicationDate: post.data.publicationTime.toDate(),
        distance: distance,
        isChallenge: uncompletedChallengesId.contains(post.id),
      );

      return postDetails;
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

final postsFeedViewModelProvider =
    AutoDisposeAsyncNotifierProvider<PostsFeedViewModel, List<PostDetails>>(
  () => PostsFeedViewModel(),
);
