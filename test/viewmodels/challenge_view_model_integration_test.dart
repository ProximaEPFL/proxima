import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:mockito/mockito.dart";
import "package:proxima/services/database/challenge_repository_service.dart";
import "package:proxima/services/database/firestore_service.dart";
import "package:proxima/services/database/user_repository_service.dart";
import "package:proxima/services/sensors/geolocation_service.dart";
import "package:proxima/viewmodels/challenge_view_model.dart";
import "package:proxima/viewmodels/login_view_model.dart";
import "package:proxima/views/components/async/circular_value.dart";

import "../mocks/data/firestore_challenge.dart";
import "../mocks/data/firestore_post.dart";
import "../mocks/data/firestore_user.dart";
import "../mocks/data/geopoint.dart";
import "../mocks/services/mock_geo_location_service.dart";

void main() {
  late MockGeoLocationService geoLocationService;
  late FakeFirebaseFirestore fakeFireStore;
  late ProviderContainer container;

  setUp(() {
    geoLocationService = MockGeoLocationService();
    fakeFireStore = FakeFirebaseFirestore();
    when(geoLocationService.getCurrentPosition()).thenAnswer(
      (_) async => userPosition1,
    );
  });

  group("Normal use", () {
    late UserRepositoryService userRepo;

    setUp(() async {
      container = ProviderContainer(
        overrides: [
          geolocationServiceProvider.overrideWithValue(geoLocationService),
          loggedInUserIdProvider.overrideWithValue(testingUserFirestoreId),
          firestoreProvider.overrideWithValue(fakeFireStore),
        ],
      );

      userRepo = container.read(userRepositoryServiceProvider);
    });

    test("No challenges are returned when the database is empty", () async {
      final challenges =
          await container.read(challengeViewModelProvider.future);
      expect(challenges, isEmpty);
    });

    test(
        "`ChallengeFirestore` is transformed correctly into `ChallengeCardData`",
        () async {
      const extraTime = Duration(hours: 2, minutes: 30);
      final challengeGenerator = FirestoreChallengeGenerator();
      final postGenerator = FirestorePostGenerator();

      final post = postGenerator.generatePostAt(
        userPosition1,
      ); // the challenge is added by hand, so we can use the user position
      await setPostFirestore(post, fakeFireStore);

      final challenge = challengeGenerator.generateChallenge(false, extraTime);
      await setChallenge(fakeFireStore, challenge, testingUserFirestoreId);

      final challenges =
          await container.read(challengeViewModelProvider.future);
      expect(challenges.length, 1);

      final uiChallenge = challenges.first;
      expect(uiChallenge.distance, 0);
      expect(
        uiChallenge.timeLeft,
        2,
      );
      expect(uiChallenge.isFinished, false);
      expect(
        uiChallenge.reward,
        ChallengeRepositoryService.soloChallengeReward,
      );
      expect(uiChallenge.title, post.data.title);
    });

    test("Completed challenge is transformed correctly", () async {
      const extraTime = Duration(hours: 2, minutes: 30);
      final challengeGenerator = FirestoreChallengeGenerator();
      final postGenerator = FirestorePostGenerator();

      final post = postGenerator.generatePostAt(
        userPosition1,
      ); // the challenge is added by hand, so we can use the user position
      await setPostFirestore(post, fakeFireStore);

      final challenge = challengeGenerator.generateChallenge(true, extraTime);
      await setChallenge(fakeFireStore, challenge, testingUserFirestoreId);

      final challenges =
          await container.read(challengeViewModelProvider.future);
      expect(challenges.length, 1);

      final uiChallenge = challenges.first;
      expect(uiChallenge.distance, null);
      expect(
        uiChallenge.timeLeft,
        2,
      );
      expect(uiChallenge.isFinished, true);
      expect(
        uiChallenge.reward,
        ChallengeRepositoryService.soloChallengeReward,
      );
      expect(uiChallenge.title, post.data.title);
    });

    test("Challenges are sorted correctly", () async {
      const extraTime = Duration(hours: 2, minutes: 30);
      final challengeGenerator = FirestoreChallengeGenerator();
      final postGenerator = FirestorePostGenerator();

      final posts = postGenerator.generatePostsAt(userPosition1, 3);
      setPostsFirestore(posts, fakeFireStore);

      final finishedChallenges =
          challengeGenerator.generateChallenges(2, true, extraTime);
      final activeChallenges =
          challengeGenerator.generateChallenges(1, false, extraTime);

      await setChallenges(
        fakeFireStore,
        finishedChallenges,
        testingUserFirestoreId,
      );
      await setChallenges(
        fakeFireStore,
        activeChallenges,
        testingUserFirestoreId,
      );

      final challenges =
          await container.read(challengeViewModelProvider.future);
      final areChallengesFinished =
          challenges.map((c) => c.isFinished).toList();

      expect(
        areChallengesFinished,
        List.filled(activeChallenges.length, false) +
            List.filled(finishedChallenges.length, true),
      );
    });

    test("Challenge can be completed", () async {
      const extraTime = Duration(hours: 2, minutes: 30);
      final challengeGenerator = FirestoreChallengeGenerator();
      final postGenerator = FirestorePostGenerator();

      await setUserFirestore(fakeFireStore, testingUserFirestore);

      final post = postGenerator.generatePostAt(
        userPosition1,
      ); // the challenge is added by hand, so we can use the user position
      await setPostFirestore(post, fakeFireStore);

      final challenge = challengeGenerator.generateChallenge(false, extraTime);
      await setChallenge(fakeFireStore, challenge, testingUserFirestoreId);

      await container
          .read(challengeViewModelProvider.notifier)
          .completeChallenge(challenge.postId);

      await Future.delayed(const Duration(milliseconds: 100));

      final challenges =
          await container.read(challengeViewModelProvider.future);
      expect(challenges.length, 1);

      final uiChallenge = challenges.first;
      expect(uiChallenge.distance, null);
      expect(
        uiChallenge.timeLeft,
        2,
      );
      expect(uiChallenge.isFinished, true);
      expect(
        uiChallenge.reward,
        ChallengeRepositoryService.soloChallengeReward,
      );
      expect(uiChallenge.title, post.data.title);

      // tests that points are added
      final updatedUser = await userRepo.getUser(testingUserFirestoreId);
      final points = updatedUser.data.centauriPoints;
      expect(points, ChallengeRepositoryService.soloChallengeReward);
    });
  });

  group("No logged in user", () {
    setUp(() async {
      container = ProviderContainer(
        overrides: [
          geolocationServiceProvider.overrideWithValue(geoLocationService),
          loggedInUserIdProvider.overrideWithValue(null),
          firestoreProvider.overrideWithValue(fakeFireStore),
        ],
      );
    });

    test("No user only throws debug error", () async {
      expect(
        () async {
          await container.read(challengeViewModelProvider.future);
        },
        throwsA(
          (exception) =>
              exception.toString().contains(CircularValue.debugErrorTag),
        ),
      );
    });
  });
}
