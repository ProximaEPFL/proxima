import "package:cloud_firestore/cloud_firestore.dart";
import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:proxima/services/database/challenge_repository_service.dart";
import "package:proxima/services/database/post_repository_service.dart";

import "../../mocks/data/mock_firestore_user.dart";
import "../../mocks/data/mock_position.dart";
import "../../mocks/data/mock_post_data.dart";

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

  group("ChallengeRepositoryService", () {
    test("Get new challenges", () async {
      const pos = userPosition0;
      final fakePosts = PostDataGenerator.generatePostData(3);
      final fakeUsers = FirestoreUserGenerator.generateUserFirestore(4);
      for (final post in fakePosts) {
        await postRepository.addPost(post, pos);
      }

      final challenges =
          await challengeRepository.getChallenges(fakeUsers[3].uid, pos);

      expect(challenges.length, 3);
      for (final challenge in challenges) {
        expect(challenge.data.isCompleted, false);
        expect(challenge.data.expiresOn.compareTo(Timestamp.now()), isPositive);

        final actualPost = await postRepository.getPost(challenge.postId);
        expect(fakePosts.contains(actualPost.data), true);
      }
    });

    test("Complete a challenge", () async {
      const pos = userPosition0;
      final fakePosts = PostDataGenerator.generatePostData(3);
      final fakeUsers = FirestoreUserGenerator.generateUserFirestore(4);
      for (final post in fakePosts) {
        postRepository.addPost(post, pos);
      }

      final challenges =
          await challengeRepository.getChallenges(fakeUsers[3].uid, pos);

      final challenge = challenges.first;
      expect(challenge.data.isCompleted, false);
      await challengeRepository.completeChallenge(
          fakeUsers[3].uid, challenge.postId);

      final updatedChallenges =
          await challengeRepository.getChallenges(fakeUsers[3].uid, pos);
      expect(updatedChallenges.length, 3);
      expect(updatedChallenges.first.data.isCompleted, true);
    });
  });
}
