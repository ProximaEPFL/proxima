import "package:cloud_firestore/cloud_firestore.dart";
import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/database/challenge/challenge_data.dart";
import "package:proxima/models/database/challenge/challenge_firestore.dart";
import "package:proxima/models/database/post/post_data.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/services/database/challenge_repository_service.dart";
import "package:proxima/services/database/post_repository_service.dart";

import "../../mocks/data/firestore_user.dart";
import "../../mocks/data/geopoint.dart";
import "../../mocks/data/post_data.dart";

Future<List<PostData>> addPosts(
  PostRepositoryService postRepository,
  GeoPoint pos,
  int n,
) async {
  final fakePosts = PostDataGenerator.generatePostData(n);
  for (final post in fakePosts) {
    await postRepository.addPost(post, pos);
  }
  return fakePosts;
}

void main() {
  late FakeFirebaseFirestore firestore;
  late PostRepositoryService postRepository;
  late ChallengeRepositoryService challengeRepository;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    postRepository = PostRepositoryService(firestore: firestore);
    challengeRepository = ChallengeRepositoryService(
      firestore: firestore,
      postRepositoryService: postRepository,
    );
  });

  const userPos = userPosition1;
  final inChallengeRange = GeoPointGenerator.createOnEdgeInsidePosition(
    userPos,
    ChallengeRepositoryService.maxChallengeRadius,
  );

  final uid = testingUserFirestoreId;

  group("ChallengeRepositoryService", () {
    test("Get new challenges", () async {
      final fakePosts = await addPosts(
        postRepository,
        inChallengeRange,
        ChallengeRepositoryService.maxActiveChallenges,
      );

      final challenges = await challengeRepository.getChallenges(uid, userPos);

      expect(challenges.length, ChallengeRepositoryService.maxActiveChallenges);
      for (final challenge in challenges) {
        expect(challenge.data.isCompleted, false);
        expect(challenge.data.expiresOn.compareTo(Timestamp.now()), isPositive);

        final actualPost = await postRepository.getPost(challenge.postId);
        expect(fakePosts.contains(actualPost.data), true);
      }
    });

    test("Complete a challenge", () async {
      await addPosts(postRepository, inChallengeRange, 1);
      final challenges = await challengeRepository.getChallenges(uid, userPos);

      final challenge = challenges.first;
      expect(challenge.data.isCompleted, false);
      await challengeRepository.completeChallenge(
        uid,
        challenge.postId,
      );

      final updatedChallenges =
          await challengeRepository.getChallenges(uid, userPos);
      expect(updatedChallenges.length, 1);
      expect(updatedChallenges.first.data.isCompleted, true);
    });

    test("Multiple gets with only one challenge available", () async {
      await addPosts(postRepository, inChallengeRange, 1);

      for (int i = 0; i < 10; i++) {
        final challenges =
            await challengeRepository.getChallenges(uid, userPos);

        expect(challenges.length, 1);
      }
    });

    test("Challenge posts are unique", () async {
      await addPosts(
        postRepository,
        inChallengeRange,
        ChallengeRepositoryService.maxActiveChallenges,
      );

      final challenges = await challengeRepository.getChallenges(
        uid,
        userPos,
      );
      final postIds = challenges.map((e) => e.postId).toSet();
      expect(postIds.length, challenges.length);
    });

    test("Deleted post disappears from challenges", () async {
      final fakePosts = PostDataGenerator.generatePostData(1);
      final postId =
          await postRepository.addPost(fakePosts.first, inChallengeRange);

      final challenges = await challengeRepository.getChallenges(uid, userPos);
      expect(challenges.length, 1);

      await postRepository.deletePost(postId);
      final updatedChallenges =
          await challengeRepository.getChallenges(uid, userPos);

      expect(updatedChallenges.length, 0);
    });

    test("Challenges expire", () async {
      const int totalChallenges =
          2 * ChallengeRepositoryService.maxActiveChallenges - 1;
      const int challengesToExpire =
          ChallengeRepositoryService.maxActiveChallenges;

      await addPosts(
        postRepository,
        inChallengeRange,
        totalChallenges,
      );
      final now = DateTime.now();
      final past =
          now.subtract(ChallengeRepositoryService.maxChallengeDuration);

      final postDocs =
          await firestore.collection(PostFirestore.collectionName).get();
      final postIds =
          postDocs.docs.map((e) => PostIdFirestore(value: e.id)).toList();

      for (int i = 0; i < challengesToExpire; i++) {
        final ChallengeFirestore challenge = ChallengeFirestore(
          postId: postIds[i],
          data: ChallengeData(
            isCompleted: false,
            expiresOn: Timestamp.fromDate(past),
          ),
        );

        await firestore
            .collection(UserFirestore.collectionName)
            .doc(uid.value)
            .collection(ChallengeFirestore.subCollectionName)
            .doc(postIds[i].value)
            .set(challenge.data.toDbData());
      }

      final updatedChallenges = await challengeRepository.getChallenges(
        uid,
        userPos,
      );

      final updatedPostIds = updatedChallenges.map((e) => e.postId).toSet();

      final expiredPostIds = postIds.sublist(0, challengesToExpire);
      final activePostIds = postIds.sublist(
        challengesToExpire,
        totalChallenges,
      );

      for (final pid in updatedPostIds) {
        expect(pid, isIn(activePostIds));
        expect(pid, isNot(isIn(expiredPostIds)));
      }
    });

    test("Challenge range works", () async {
      final tooFarPos = GeoPointGenerator.createOnEdgeOutsidePosition(
        userPos,
        ChallengeRepositoryService.maxChallengeRadius,
      );

      final tooClosePos = GeoPointGenerator.createOnEdgeInsidePosition(
        userPos,
        ChallengeRepositoryService.minChallengeRadius,
      );

      await addPosts(postRepository, tooFarPos, 1);
      await addPosts(postRepository, tooClosePos, 1);
      var challenges = await challengeRepository.getChallenges(uid, userPos);
      expect(challenges.length, 0);

      await addPosts(postRepository, inChallengeRange, 1);
      challenges = await challengeRepository.getChallenges(uid, userPos);
      expect(challenges.length, 1);
    });
  });
}
