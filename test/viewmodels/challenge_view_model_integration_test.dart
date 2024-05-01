import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:mockito/mockito.dart";
import "package:proxima/services/database/challenge_repository_service.dart";
import "package:proxima/services/database/post_repository_service.dart";
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
  late FakeFirebaseFirestore fakeFireStore;

  late UserRepositoryService userRepo;
  late PostRepositoryService postRepo;
  late ChallengeRepositoryService challengeRepo;

  late ProviderContainer container;

  setUp(() async {
    fakeFireStore = FakeFirebaseFirestore();
    geoLocationService = MockGeoLocationService();

    userRepo = UserRepositoryService(
      firestore: fakeFireStore,
    );
    postRepo = PostRepositoryService(
      firestore: fakeFireStore,
    );
    challengeRepo = ChallengeRepositoryService(
      firestore: fakeFireStore,
      userRepositoryService: userRepo,
      postRepositoryService: postRepo,
    );

    container = ProviderContainer(
      overrides: [
        geoLocationServiceProvider.overrideWithValue(geoLocationService),
        userRepositoryProvider.overrideWithValue(userRepo),
        postRepositoryProvider.overrideWithValue(postRepo),
        challengeRepositoryServiceProvider.overrideWithValue(challengeRepo),
        uidProvider.overrideWithValue(testingUserFirestoreId),
      ],
    );

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

    final challenge = challengeGenerator.generate(false, extraTime);
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

    final challenge = challengeGenerator.generate(true, extraTime);
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
}
