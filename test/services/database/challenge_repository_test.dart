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

import "../../mocks/data/mock_firestore_user.dart";
import "../../mocks/data/mock_position.dart";
import "../../mocks/data/mock_post_data.dart";

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
  final inChallengeRange = GeoPointGenerator().createPostOnEdgeInsidePosition(
    userPos,
    ChallengeRepositoryService.maxChallengeRadius,
  );

  final uid = testingUserFirestoreId;

  group("ChallengeRepositoryService", () {
    test("Get new challenges", () async {
      final fakePosts = await addPosts(postRepository, inChallengeRange, 3);

      final challenges = await challengeRepository.getChallenges(uid, userPos);

      expect(challenges.length, 3);
      for (final challenge in challenges) {
        expect(challenge.data.isCompleted, false);
        expect(challenge.data.expiresOn.compareTo(Timestamp.now()), isPositive);

        final actualPost = await postRepository.getPost(challenge.postId);
        expect(fakePosts.contains(actualPost.data), true);
      }
    });

    test("Complete a challenge", () async {
      final fakePosts = await addPosts(postRepository, inChallengeRange, 1);

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
      final fakePosts = await addPosts(postRepository, inChallengeRange, 1);

      for (int i = 0; i < 10; i++) {
        final challenges =
            await challengeRepository.getChallenges(uid, userPos);

        expect(challenges.length, 1);
      }
    });

    test("Challenge posts are unique", () async {
      final fakePosts = await addPosts(postRepository, inChallengeRange, 3);

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
      final fakePosts = await addPosts(postRepository, inChallengeRange, 5);

      final now = DateTime.now();
      final past =
          now.subtract(ChallengeRepositoryService.maxChallengeDuration);

      final postDocs =
          await firestore.collection(PostFirestore.collectionName).get();
      final postIds =
          postDocs.docs.map((e) => PostIdFirestore(value: e.id)).toList();

      for (int i = 0; i < 3; i++) {
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

      for (final pid in updatedPostIds) {
        expect(pid, isIn(postIds.sublist(3, 5)));
      }
    });
  });
}
