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

import "../../mocks/data/challenge_data.dart";
import "../../mocks/data/firestore_user.dart";
import "../../mocks/data/geopoint.dart";
import "../../mocks/data/post_data.dart";

/// Add [n] posts at position [pos] and return their data and the [PostFirestore] objects
Future<List<PostFirestore>> addPosts(
  PostRepositoryService postRepository,
  GeoPoint pos,
  int n,
) async {
  final List<PostFirestore> fakePosts = List.empty(growable: true);
  final fakePostsData = PostDataGenerator.generatePostData(n);
  for (final data in fakePostsData) {
    final id = await postRepository.addPost(data, pos);
    final fakePost = await postRepository.getPost(
      id,
    ); // I don't wanna look into how the position works, this is easier
    fakePosts.add(fakePost);
  }
  return fakePosts;
}

/// Add [n] posts at position [pos] and return their data
Future<List<PostData>> addPostsReturnDataOnly(
  PostRepositoryService postRepository,
  GeoPoint pos,
  int n,
) async {
  return (await addPosts(postRepository, pos, n)).map((e) => e.data).toList();
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

  group("Challenge repository getter", () {
    test("Get new challenges", () async {
      final fakePosts = await addPostsReturnDataOnly(
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

    test("Multiple gets with only one challenge available", () async {
      await addPostsReturnDataOnly(postRepository, inChallengeRange, 1);

      for (int i = 0; i < 10; i++) {
        final challenges =
            await challengeRepository.getChallenges(uid, userPos);

        expect(challenges.length, 1);
      }
    });

    test("Challenge posts are unique", () async {
      await addPostsReturnDataOnly(
        postRepository,
        inChallengeRange,
        ChallengeRepositoryService.maxActiveChallenges,
      );

      final challenges = await challengeRepository.getChallenges(
        uid,
        userPos,
      );
      final postIds = challenges.map((challenge) => challenge.postId).toSet();
      expect(postIds.length, challenges.length);
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

      await addPostsReturnDataOnly(postRepository, tooFarPos, 1);
      await addPostsReturnDataOnly(postRepository, tooClosePos, 1);
      var challenges = await challengeRepository.getChallenges(uid, userPos);
      expect(challenges.length, 0);

      await addPostsReturnDataOnly(postRepository, inChallengeRange, 1);
      challenges = await challengeRepository.getChallenges(uid, userPos);
      expect(challenges.length, 1);
    });
  });

  group("Challenges update correctly", () {
    test("Deleted post disappears from challenges", () async {
      final fakePosts = await addPosts(
        postRepository,
        inChallengeRange,
        2,
      );

      final challenges = await challengeRepository.getChallenges(uid, userPos);
      expect(challenges.length, 2);

      await postRepository.deletePost(fakePosts[0].id);
      final updatedChallenges =
          await challengeRepository.getChallenges(uid, userPos);

      expect(updatedChallenges.length, 1);
      expect(updatedChallenges.first.postId, fakePosts[1].id);
    });

    test("Past challenge does not reappear", () async {
      final posts = PostDataGenerator.generatePostData(2);
      final pastPost = posts[0];
      final availablePost = posts[1];

      final pastPostId =
          await postRepository.addPost(pastPost, inChallengeRange);
      final availablePostId =
          await postRepository.addPost(availablePost, inChallengeRange);

      // does not matter
      final data = ChallengeGenerator.generate();

      await firestore
          .collection(UserFirestore.collectionName)
          .doc(uid.value)
          .collection(ChallengeFirestore.pastChallengesSubCollectionName)
          .doc(pastPostId.value)
          .set(data.toDbData());

      final challenges = await challengeRepository.getChallenges(uid, userPos);

      expect(challenges.length, 1);
      expect(challenges.first.postId, availablePostId);
    });

    test("Challenges expire", () async {
      const int totalChallenges =
          2 * ChallengeRepositoryService.maxActiveChallenges - 1;
      const int challengesToExpire =
          ChallengeRepositoryService.maxActiveChallenges;

      await addPostsReturnDataOnly(
        postRepository,
        inChallengeRange,
        totalChallenges,
      );
      final now = DateTime.now();
      final past = now.subtract(const Duration(seconds: 1));

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
  });

  group("Challenge completion", () {
    test("Complete a challenge", () async {
      await addPostsReturnDataOnly(postRepository, inChallengeRange, 1);
      final challenges = await challengeRepository.getChallenges(uid, userPos);
      expect(challenges.length, 1);

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
  });
}
