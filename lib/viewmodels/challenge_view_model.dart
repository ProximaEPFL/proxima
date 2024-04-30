import "package:geoflutterfire_plus/geoflutterfire_plus.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/challenge_card_data.dart";
import "package:proxima/services/database/challenge_repository_service.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/services/geolocation_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";

// TODO: For now, this is duplicated code with the mock from the tests.
// This will just be replaced when we implement a real view model anyway.
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
      final double distanceKm = GeoFirePoint(currentPosition)
          .distanceBetweenInKm(geopoint: post.location.geoPoint);
      final int distanceM = (distanceKm * 1000).toInt();

      final timeLeft = challenge.data.expiresOn.toDate().difference(now);

      return ChallengeCardData.solo(
        title: post.data.title,
        distance: distanceM,
        timeLeft: timeLeft.inHours,
        reward: 500,
      );
    });

    return Future.wait(uiChallenges);
  }
}

final challengeProvider =
    AsyncNotifierProvider<ChallengeViewModel, List<ChallengeCardData>>(
  () => ChallengeViewModel(),
);
