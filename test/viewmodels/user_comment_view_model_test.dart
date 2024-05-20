import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/comment/comment_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/models/ui/user_comment_details.dart";
import "package:proxima/services/database/comment/comment_repository_service.dart";
import "package:proxima/services/database/firestore_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";
import "package:proxima/viewmodels/user_comments_view_model.dart";

import "../mocks/data/firestore_comment.dart";
import "../mocks/data/firestore_user.dart";

void main() {
  group("Testing user comment view model", () {
    late FakeFirebaseFirestore firestore;
    late CommentRepositoryService commentRepository;
    late CommentFirestoreGenerator commentGenerator;

    late ProviderContainer container;
    late UserIdFirestore userId;

    setUp(() async {
      firestore = FakeFirebaseFirestore();
      commentGenerator = CommentFirestoreGenerator();

      userId = testingUserFirestoreId;

      container = ProviderContainer(
        overrides: [
          firestoreProvider.overrideWithValue(firestore),
          loggedInUserIdProvider.overrideWithValue(userId),
        ],
      );

      commentRepository = container.read(commentRepositoryServiceProvider);
    });

    group("Ordering", () {
      /// Get the [CommentFirestore] from the list [comments] that corresponds
      /// to the [userCommentDetails].
      CommentFirestore getCorrespondingComment(
        UserCommentDetails userCommentDetails,
        List<CommentFirestore> comments,
      ) {
        // Check that the comment list contains exactly one comment with the same id
        final correspondingComments = comments.where(
          (comment) => comment.id == userCommentDetails.commentId,
        );
        expect(correspondingComments, hasLength(1));

        return correspondingComments.first;
      }

      test("Comments are ordered from latest to oldest", () async {
        const nbComments = 50;

        // Add comments to the firestore
        final (commentsFirestore, _) =
            await commentGenerator.addCommentsForUser(
          nbComments,
          userId,
          commentRepository,
          firestore,
        );

        // Get the user comments
        final commentDetails =
            await container.read(userCommentsViewModelProvider.future);
        expect(commentDetails, hasLength(nbComments));

        // Check that the comments are ordered from latest to oldest
        for (var i = 0; i < commentDetails.length - 1; i++) {
          final commentDetailsAbove = commentDetails[i];
          final commentDetailsBelow = commentDetails[i + 1];

          final commentAbove =
              getCorrespondingComment(commentDetailsAbove, commentsFirestore);
          final commentBelow =
              getCorrespondingComment(commentDetailsBelow, commentsFirestore);

          expect(
            commentAbove.data.publicationTime.microsecondsSinceEpoch,
            greaterThanOrEqualTo(
              commentBelow.data.publicationTime.microsecondsSinceEpoch,
            ),
          );
        }
      });
    });

    test("Empty comments are exposed correctly", () async {
      final comments =
          await container.read(userCommentsViewModelProvider.future);
      expect(comments, isEmpty);
    });
  });
}
