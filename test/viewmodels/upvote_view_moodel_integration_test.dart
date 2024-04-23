import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/models/database/vote/upvote_state.dart";
import "package:proxima/models/ui/post_vote.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/services/database/post_upvote_repository_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";
import "package:proxima/viewmodels/upvote_view_model.dart";

import "../mocks/data/mock_firestore_user.dart";
import "../mocks/data/mock_position.dart";
import "../mocks/data/mock_post_data.dart";

void main() {
  group("UpVote ViewModel integration testing", () {
    late FakeFirebaseFirestore fakeFireStore;

    late PostUpvoteRepositoryService voteRepository;
    late PostRepositoryService postRepository;
    late PostFirestore testingPost;
    late UserIdFirestore userId;

    late AutoDisposeFamilyAsyncNotifierProvider<UpVoteViewModel, PostVote,
        ({PostIdFirestore postId})> voteViewModelProvider;

    late ProviderContainer container;

    setUp(() async {
      fakeFireStore = FakeFirebaseFirestore();

      voteRepository = PostUpvoteRepositoryService(firestore: fakeFireStore);
      postRepository = PostRepositoryService(firestore: fakeFireStore);

      // Add a post to the database
      final testingPostData = MockPostFirestore.createUserPost(
        testingUserFirestoreId,
        userPosition0,
      ).data;

      userId = testingUserFirestoreId;

      final postId =
          await postRepository.addPost(testingPostData, userPosition0);
      testingPost = await postRepository.getPost(postId);

      container = ProviderContainer(
        overrides: [
          postRepositoryProvider.overrideWithValue(postRepository),
          postUpvoteRepositoryProvider.overrideWithValue(voteRepository),
          uidProvider.overrideWithValue(userId),
        ],
      );

      voteViewModelProvider = postVoteProvider((postId: testingPost.id));
    });

    test("Upvote correctly updates the state and vote count on the database",
        () async {
      await container.read(voteViewModelProvider.notifier).triggerUpVote();

      final updatedPost = await postRepository.getPost(testingPost.id);
      final updatedVoteState =
          await voteRepository.getUpvoteState(userId, testingPost.id);

      expect(updatedPost.data.voteScore, testingPost.data.voteScore + 1);
      expect(updatedVoteState, UpvoteState.upvoted);
    });

    test("Downvote correctly updates the state and vote count on the database",
        () async {
      await container.read(voteViewModelProvider.notifier).triggerDownVote();

      final updatedPost = await postRepository.getPost(testingPost.id);
      final updatedVoteState =
          await voteRepository.getUpvoteState(userId, testingPost.id);

      expect(updatedPost.data.voteScore, testingPost.data.voteScore - 1);
      expect(updatedVoteState, UpvoteState.downvoted);
    });

    test("Upvoting twice correctly add then removes the upvote on the database",
        () async {
      // Perform first upvote
      await container.read(voteViewModelProvider.notifier).triggerUpVote();

      final updatedPostFirstUpvote =
          await postRepository.getPost(testingPost.id);
      final updatedVoteStateFirstUpvote =
          await voteRepository.getUpvoteState(userId, testingPost.id);

      expect(
        updatedPostFirstUpvote.data.voteScore,
        testingPost.data.voteScore + 1,
      );
      expect(updatedVoteStateFirstUpvote, UpvoteState.upvoted);

      // Perform second upvote
      await container.read(voteViewModelProvider.notifier).triggerUpVote();

      final updatedPostSecondUpvote =
          await postRepository.getPost(testingPost.id);
      final updatedVoteStateSecondUpvote =
          await voteRepository.getUpvoteState(userId, testingPost.id);

      expect(
        updatedPostSecondUpvote.data.voteScore,
        testingPost.data.voteScore,
      );
      expect(updatedVoteStateSecondUpvote, UpvoteState.none);
    });

    test("Upvoting then downvoting correctly removes 2 votes on the database",
        () async {
      // Perform upvote
      await container.read(voteViewModelProvider.notifier).triggerUpVote();

      final updatedPostFirstUpvote =
          await postRepository.getPost(testingPost.id);
      final updatedVoteStateFirstUpvote =
          await voteRepository.getUpvoteState(userId, testingPost.id);

      expect(
        updatedPostFirstUpvote.data.voteScore,
        testingPost.data.voteScore + 1,
      );
      expect(updatedVoteStateFirstUpvote, UpvoteState.upvoted);

      // Perform downvote
      await container.read(voteViewModelProvider.notifier).triggerDownVote();

      final updatedPostSecondUpvote =
          await postRepository.getPost(testingPost.id);
      final updatedVoteStateSecondUpvote =
          await voteRepository.getUpvoteState(userId, testingPost.id);

      expect(
        updatedPostSecondUpvote.data.voteScore,
        testingPost.data.voteScore - 1,
      );
      expect(updatedVoteStateSecondUpvote, UpvoteState.downvoted);
    });
  });
}
