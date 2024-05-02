import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/comment/comment_id_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/models/database/vote/upvote_state.dart";
import "package:proxima/services/database/comment_repository_service.dart";
import "package:proxima/services/database/comment_upvote_repository_service.dart";
import "package:proxima/services/database/firestore_service.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/services/database/upvote_repository_service.dart";

import "../../mocks/data/comment_data.dart";
import "../../mocks/data/firestore_user.dart";
import "../../mocks/data/geopoint.dart";
import "../../mocks/data/post_data.dart";

void main() {
  group("Testing comment upvote repository", () {
    late FakeFirebaseFirestore firestore;
    late PostRepositoryService postRepository;
    late CommentRepositoryService commentRepository;
    late UpvoteRepositoryService<CommentIdFirestore> commentUpvoteRepository;
    late CommentDataGenerator commentDataGenerator;

    late PostIdFirestore postId;
    late CommentIdFirestore commentId;

    setUp(() async {
      firestore = FakeFirebaseFirestore();
      postRepository = PostRepositoryService(firestore: firestore);
      commentRepository = CommentRepositoryService(firestore: firestore);
      commentDataGenerator = CommentDataGenerator();

      final container = ProviderContainer(
        overrides: [
          firestoreProvider.overrideWithValue(firestore),
        ],
      );

      // Add a post on which the comments will be added
      final postData = PostDataGenerator().postData;
      postId = await postRepository.addPost(postData, userPosition0);

      // Get the comment upvote repository for the post
      commentUpvoteRepository =
          container.read(commentUpvoteRepositoryProvider(postId));

      // Add a comment to the post
      final commentData =
          commentDataGenerator.createRandomCommentData(voteScore: 0);

      commentId = await commentRepository.addComment(
        postId,
        commentData,
      );
    });

    group("Single user voting", () {
      late UserIdFirestore userId;

      setUp(() {
        userId = testingUserFirestoreId;
      });

      test("Comment upvote state is none by default", () async {
        const expectedUpvoteState = UpvoteState.none;

        final actualUpvoteState = await commentUpvoteRepository.getUpvoteState(
          userId,
          commentId,
        );

        expect(actualUpvoteState, expectedUpvoteState);
      });

      test("Upvoting a comment correctly", () async {
        const upvoteState = UpvoteState.upvoted;
        await commentUpvoteRepository.setUpvoteState(
          userId,
          commentId,
          upvoteState,
        );

        // Check that the votescore of the comment is updated
        final comments = await commentRepository.getComments(postId);
        final comment = comments.first;

        expect(comment.data.voteScore, 1);

        // Check that the upvote state is updated
        final actualUpvoteState = await commentUpvoteRepository.getUpvoteState(
          userId,
          commentId,
        );

        expect(actualUpvoteState, upvoteState);
      });
    });

    group("Multiple users voting", () {
      test("Upvotes and downvotes combination", () async {
        const numberOfUsers = 20;
        final users =
            FirestoreUserGenerator.generateUserFirestore(numberOfUsers);

        const moduloDownvote = 5;
        int expectedVoteScore = 0;

        for (var i = 0; i < numberOfUsers; i++) {
          final user = users[i];
          final upvoteState = i % moduloDownvote == 0
              ? UpvoteState.downvoted
              : UpvoteState.upvoted;

          expectedVoteScore += upvoteState.increment;

          await commentUpvoteRepository.setUpvoteState(
            user.uid,
            commentId,
            upvoteState,
          );
        }

        // Check that the votescore of the comment is updated
        final comments = await commentRepository.getComments(postId);
        final comment = comments.first;

        expect(comment.data.voteScore, expectedVoteScore);
      });
    });
  });
}
