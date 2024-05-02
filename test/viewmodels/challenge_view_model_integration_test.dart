import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:mockito/mockito.dart";
import "package:proxima/services/database/challenge_repository_service.dart";
import "package:proxima/services/database/firestore_service.dart";
import "package:proxima/services/database/user_repository_service.dart";
import "package:proxima/services/geolocation_service.dart";
import "package:proxima/viewmodels/challenge_view_model.dart";
import "package:proxima/viewmodels/login_view_model.dart";

import "../mocks/data/firestore_challenge.dart";
import "../mocks/data/firestore_post.dart";
import "../mocks/data/firestore_user.dart";
import "../mocks/data/geopoint.dart";
import "../mocks/services/mock_geo_location_service.dart";

void main() {
  late MockGeoLocationService geoLocationService;
  late UserRepositoryService userRepo;
  late FakeFirebaseFirestore fakeFireStore;
  late ProviderContainer container;

  setUp(() async {
    geoLocationService = MockGeoLocationService();
    fakeFireStore = FakeFirebaseFirestore();

    container = ProviderContainer(
      overrides: [
        geoLocationServiceProvider.overrideWithValue(geoLocationService),
        uidProvider.overrideWithValue(testingUserFirestoreId),
        firestoreProvider.overrideWithValue(fakeFireStore),
      ],
    );

    userRepo = container.read(userRepositoryProvider);

    when(geoLocationService.getCurrentPosition()).thenAnswer(
      (_) async => userPosition1,
    );
  });

  test("No challenges are returned when the database is empty", () async {
    final challenges = await container.read(challengeProvider.future);
    expect(challenges, isEmpty);
  });

  test("Active challenge is transformed correctly", () async {
    const extraTime = Duration(hours: 3);
    final challengeGenerator = FirestoreChallengeGenerator();
    final postGenerator = FirestorePostGenerator();

    final post = postGenerator.generatePostAt(
      userPosition1,
    ); // the challenge is added by hand, so we can use the user position
    await setPostFirestore(post, fakeFireStore);

    final challenge = challengeGenerator.generateChallenge(false, extraTime);
    await setChallenge(fakeFireStore, challenge, testingUserFirestoreId);

    final challenges = await container.read(challengeProvider.future);
    expect(challenges.length, 1);

    final uiChallenge = challenges.first;
    expect(uiChallenge.distance, 0);
    expect(
      uiChallenge.timeLeft,
      anyOf(2, 3),
    ); // 3 hours - 1 second or 3 hours - 0 seconds (we can't bet on the time of the above execution)
    expect(uiChallenge.isFinished, false);
    expect(uiChallenge.reward, ChallengeRepositoryService.soloChallengeReward);
    expect(uiChallenge.title, post.data.title);
  });

  test("Completed challenge is transformed correctly", () async {
    const extraTime = Duration(hours: 3);
    final challengeGenerator = FirestoreChallengeGenerator();
    final postGenerator = FirestorePostGenerator();

    final post = postGenerator.generatePostAt(
      userPosition1,
    ); // the challenge is added by hand, so we can use the user position
    await setPostFirestore(post, fakeFireStore);

    final challenge = challengeGenerator.generateChallenge(true, extraTime);
    await setChallenge(fakeFireStore, challenge, testingUserFirestoreId);

    final challenges = await container.read(challengeProvider.future);
    expect(challenges.length, 1);

    final uiChallenge = challenges.first;
    expect(uiChallenge.distance, null);
    expect(
      uiChallenge.timeLeft,
      anyOf(2, 3),
    ); // 3 hours - 1 second or 3 hours - 0 seconds (we can't bet on the time of the above execution)
    expect(uiChallenge.isFinished, true);
    expect(uiChallenge.reward, ChallengeRepositoryService.soloChallengeReward);
    expect(uiChallenge.title, post.data.title);
  });

  test("Challenges are sorted correctly", () async {
    const extraTime = Duration(hours: 3);
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

    final challenges = await container.read(challengeProvider.future);
    final areChallengesFinished = challenges.map((c) => c.isFinished).toList();

    expect(areChallengesFinished, [false, true, true]);
  });

  test("Challenge can be completed", () async {
    const extraTime = Duration(hours: 3);
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
        .read(challengeProvider.notifier)
        .completeChallenge(challenge.postId);

    await Future.delayed(const Duration(milliseconds: 100));

    final challenges = await container.read(challengeProvider.future);
    expect(challenges.length, 1);

    final uiChallenge = challenges.first;
    expect(uiChallenge.distance, null);
    expect(
      uiChallenge.timeLeft,
      anyOf(2, 3),
    ); // 3 hours - 1 second or 3 hours - 0 seconds (we can't bet on the time of the above execution)
    expect(uiChallenge.isFinished, true);
    expect(uiChallenge.reward, ChallengeRepositoryService.soloChallengeReward);
    expect(uiChallenge.title, post.data.title);

    // tests that points are added
    final updatedUser = await userRepo.getUser(testingUserFirestoreId);
    final points = updatedUser.data.centauriPoints;
    expect(points, ChallengeRepositoryService.soloChallengeReward);
  });
}
