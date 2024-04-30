import "package:geoflutterfire_plus/geoflutterfire_plus.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/ui/challenge_card_data.dart";
import "package:proxima/services/database/challenge_repository_service.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/services/geolocation_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";

class ChallengeViewModel extends AsyncNotifier<List<ChallengeCardData>> {
  @override
  Future<List<ChallengeCardData>> build() async {
    final geoLocationService = ref.watch(geoLocationServiceProvider);
    final challengeRepository = ref.watch(challengeRepositoryServiceProvider);

    final currentPosition = await geoLocationService.getCurrentPosition();
    final currentUser = ref.watch(uidProvider);

    final firestoreChallenges = await challengeRepository.getChallenges(
      currentUser!,
      currentPosition,
    );

    final postRepository = ref.watch(postRepositoryProvider);
    final now = DateTime.now();
    Iterable<Future<ChallengeCardData>> uiChallenges =
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

    return Future.wait(uiChallenges);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

final challengeProvider =
    AsyncNotifierProvider<ChallengeViewModel, List<ChallengeCardData>>(
  () => ChallengeViewModel(),
);
