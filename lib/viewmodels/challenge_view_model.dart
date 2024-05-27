import "package:geoflutterfire_plus/geoflutterfire_plus.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/ui/challenge_details.dart";
import "package:proxima/services/database/challenge_repository_service.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/services/sensors/geolocation_service.dart";
import "package:proxima/viewmodels/dynamic_user_avatar_view_model.dart";
import "package:proxima/viewmodels/login_view_model.dart";
import "package:proxima/viewmodels/map/map_pin_view_model.dart";

/// This viewmodel is used to fetch the list of challenges that are displayed in
/// the challenge feed. It fetches the challenges from the database and sorts
/// them by putting the finished challenges at the end of the list. It transforms
/// the challenges into [ChallengeDetails] objects to be displayed, by getting
/// the posts from the post repository and calculating the distances as well as
/// remaining time.
/// It extends [AutoDisposeAsyncNotifier] to automatically dispose of the viewmodel
/// so that the challenges are refreshed when the view is no longer visible.
class ChallengeViewModel
    extends AutoDisposeAsyncNotifier<List<ChallengeDetails>> {
  @override
  Future<List<ChallengeDetails>> build() async {
    final geoLocationService = ref.watch(geolocationServiceProvider);
    final challengeRepository = ref.watch(challengeRepositoryServiceProvider);

    final currentPosition = await geoLocationService.getCurrentPosition();
    final currentUser = ref.watch(validLoggedInUserIdProvider);

    final firestoreChallenges = await challengeRepository.getChallenges(
      currentUser,
      currentPosition,
    );

    final postRepository = ref.watch(postRepositoryServiceProvider);
    final now = DateTime.now();
    final Iterable<Future<ChallengeDetails>> futureUiChallenges =
        firestoreChallenges.map((challenge) async {
      final post = await postRepository.getPost(challenge.postId);
      final timeLeft = challenge.data.expiresOn.toDate().difference(now);

      if (!challenge.data.isCompleted) {
        final double distanceKm = GeoFirePoint(currentPosition)
            .distanceBetweenInKm(geopoint: post.location.geoPoint);
        final int distanceM = (distanceKm * 1000).toInt();

        return ChallengeDetails.solo(
          title: post.data.title,
          distance: distanceM,
          timeLeft: timeLeft.inHours,
          reward: ChallengeRepositoryService.soloChallengeReward,
        );
      } else {
        return ChallengeDetails.soloFinished(
          title: post.data.title,
          timeLeft: timeLeft.inHours,
          reward: ChallengeRepositoryService.soloChallengeReward,
        );
      }
    });

    final uiChallenges = await Future.wait(futureUiChallenges);
    uiChallenges.sort((a, b) {
      if (a.isFinished == b.isFinished) {
        return 0;
      }

      return b.isFinished ? -1 : 1;
    }); // sort the list so that finished challenges appear last

    return uiChallenges;
  }

  /// Refresh the list of challenges
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  /// Complete a challenge associated with post of id [pid]. Returns the number
  /// of points that was awarded if the challenge was indeed completed. Returns
  /// null if the challenge could not be completed. This could be because the
  /// post given was not a challenge, was expired, or was already completed.
  /// The future completes as soon as the boolean is known, the viewmodel might
  /// take longer to update (it is not awaited on).
  Future<int?> completeChallenge(PostIdFirestore pid) async {
    final currentUser = ref.read(validLoggedInUserIdProvider);
    final challengeRepository = ref.read(challengeRepositoryServiceProvider);

    final pointsAwarded =
        await challengeRepository.completeChallenge(currentUser, pid);
    if (pointsAwarded != null) {
      // we only need to refresh the view model if something actually changed
      // we do not need to wait for this refresh, as most likely we will not
      // actually call this method from inside the challenge UI
      // if we do we might have a weird double loading, but probably not
      // can change if we have a problem
      refresh();

      // Refresh the map pins after challenge completion
      ref.read(mapPinViewModelProvider.notifier).refresh();

      // Refresh the user centauri points after challenge completion
      // Note: null is the current user id as represented in dynamicUserAvatarViewModelProvider
      // So we have to refresh both [currentUser] and the null user
      for (final user in [null, currentUser]) {
        ref.read(dynamicUserAvatarViewModelProvider(user).notifier).refresh();
      }
    }

    return pointsAwarded;
  }
}

final challengeViewModelProvider = AutoDisposeAsyncNotifierProvider<
    ChallengeViewModel, List<ChallengeDetails>>(
  () => ChallengeViewModel(),
);
