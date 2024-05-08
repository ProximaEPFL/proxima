import "package:geoflutterfire_plus/geoflutterfire_plus.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/ui/challenge_card_data.dart";
import "package:proxima/services/database/challenge_repository_service.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/services/geolocation_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";

/// This viewmodel is used to fetch the list of challenges that are displayed in
/// the challenge feed. It fetches the challenges from the database and sorts
/// them by putting the finished challenges at the end of the list. It transforms
/// the challenges into [ChallengeCardData] objects to be displayed, by getting
/// the posts from the post repository and calculating the distances as well as
/// remaining time.
class ChallengeViewModel extends AsyncNotifier<List<ChallengeCardData>> {
  @override
  Future<List<ChallengeCardData>> build() async {
    final geoLocationService = ref.watch(geoLocationServiceProvider);
    final challengeRepository = ref.watch(challengeRepositoryServiceProvider);

    final currentPosition = await geoLocationService.getCurrentPosition();
    final currentUser = ref.watch(validUidProvider);

    final firestoreChallenges = await challengeRepository.getChallenges(
      currentUser,
      currentPosition,
    );

    final postRepository = ref.watch(postRepositoryProvider);
    final now = DateTime.now();
    final Iterable<Future<ChallengeCardData>> futureUiChallenges =
        firestoreChallenges.map((challenge) async {
      final post = await postRepository.getPost(challenge.postId);
      final timeLeft = challenge.data.expiresOn.toDate().difference(now);

      if (!challenge.data.isCompleted) {
        final double distanceKm = GeoFirePoint(currentPosition)
            .distanceBetweenInKm(geopoint: post.location.geoPoint);
        final int distanceM = (distanceKm * 1000).toInt();

        return ChallengeCardData.solo(
          title: post.data.title,
          distance: distanceM,
          timeLeft: timeLeft.inHours,
          reward: ChallengeRepositoryService.soloChallengeReward,
        );
      } else {
        return ChallengeCardData.soloFinished(
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
    final currentUser = ref.read(validUidProvider);
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
    }
    return pointsAwarded;
  }
}

final challengeProvider =
    AsyncNotifierProvider<ChallengeViewModel, List<ChallengeCardData>>(
  () => ChallengeViewModel(),
);
