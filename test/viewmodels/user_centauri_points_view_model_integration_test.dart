import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/services/database/challenge_repository_service.dart";
import "package:proxima/services/database/firestore_service.dart";
import "package:proxima/viewmodels/challenge_view_model.dart";
import "package:proxima/viewmodels/login_view_model.dart";
import "package:proxima/viewmodels/user_centauri_points_view_model.dart";

import "../mocks/data/firestore_challenge.dart";
import "../mocks/data/firestore_post.dart";
import "../mocks/data/firestore_user.dart";
import "../mocks/data/geopoint.dart";
import "../utils/delay_async_func.dart";

void main() {
  late FakeFirebaseFirestore fakeFireStore;
  late ProviderContainer container;

  setUp(() {
    fakeFireStore = FakeFirebaseFirestore();
  });

  group("User Centauri points ViewModel integration testing using challenges",
      () {
    late FirestoreChallengeGenerator challengeGenerator;
    late FirestorePostGenerator postGenerator;

    setUp(() async {
      container = ProviderContainer(
        overrides: [
          loggedInUserIdProvider.overrideWithValue(testingUserFirestoreId),
          firestoreProvider.overrideWithValue(fakeFireStore),
        ],
      );
      challengeGenerator = FirestoreChallengeGenerator();
      postGenerator = FirestorePostGenerator();

      await setUserFirestore(fakeFireStore, testingUserFirestore);

      final post = postGenerator.generatePostAt(
        userPosition1,
      );
      await setPostFirestore(post, fakeFireStore);
    });

    test("On challenge completion check centauri points refresh", () async {
      // Check the initial number of centauri points
      final centauriPointsBeforeChallengeCompletion = await container.read(
        userCentauriPointsViewModelProvider(testingUserFirestoreId).future,
      );
      expect(
        centauriPointsBeforeChallengeCompletion,
        testingUserData.centauriPoints,
      );

      // Generate a challenge
      final challenge = challengeGenerator.generateChallenge(
        false,
        const Duration(hours: 2, minutes: 30),
      );
      await setChallenge(fakeFireStore, challenge, testingUserFirestoreId);

      await container
          .read(challengeViewModelProvider.notifier)
          .completeChallenge(challenge.postId);

      await Future.delayed(delayNeededForAsyncFunctionExecution);

      // Check the final number of centauri points
      final centauriPointsAfterChallengeCompletion = await container.read(
        userCentauriPointsViewModelProvider(testingUserFirestoreId).future,
      );
      expect(
        centauriPointsAfterChallengeCompletion,
        testingUserData.centauriPoints +
            ChallengeRepositoryService.soloChallengeReward,
      );
    });
  });
}
