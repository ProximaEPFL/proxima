import "package:collection/collection.dart";
import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/comment/comment_data.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/ui/comment_details.dart";
import "package:proxima/services/database/comment/comment_repository_service.dart";
import "package:proxima/services/database/firestore_service.dart";
import "package:proxima/services/database/user_repository_service.dart";
import "package:proxima/viewmodels/comments_view_model.dart";

import "../mocks/data/comment_data.dart";
import "../mocks/data/firestore_post.dart";
import "../mocks/data/firestore_user.dart";
import "../mocks/data/geopoint.dart";

void main() {
  group("Testing comment view model", () {
    late FakeFirebaseFirestore fakeFirestore;
    late CommentDataGenerator commentDataGenerator;

    late UserRepositoryService userRepository;
    late CommentRepositoryService commentRepository;
    late AutoDisposeFamilyAsyncNotifierProvider<CommentsViewModel,
        List<CommentDetails>, PostIdFirestore> commentViewModelProvider;
    late ProviderContainer container;

    late PostIdFirestore postId;

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      commentDataGenerator = CommentDataGenerator();

      container = ProviderContainer(
        overrides: [
          firestoreProvider.overrideWithValue(fakeFirestore),
        ],
      );

      userRepository = container.read(userRepositoryServiceProvider);
      commentRepository = container.read(commentRepositoryServiceProvider);

      final post = FirestorePostGenerator().generatePostAt(userPosition0);
      await setPostFirestore(post, fakeFirestore);
      postId = post.id;

      commentViewModelProvider = commentsViewModelProvider(postId);
    });

    group("display of comments", () {
      test("No comments are returned when the database is empty", () async {
        final comments = await container.read(commentViewModelProvider.future);

        expect(comments, isEmpty);
      });

      test("Multiple comments are returned when the database has comments",
          () async {
        const numberOwners = 3;
        const numberComments = 19;

        // Create and add the comments owner to the database
        final owners =
            await FirestoreUserGenerator.addUsers(fakeFirestore, numberOwners);

        // Create and add the comments to the database
        final commentsData = commentDataGenerator
            .generateCommentData(numberComments)
            .mapIndexed(
              (index, commentData) => CommentData(
                ownerId: owners[index % numberOwners].uid,
                publicationTime: commentData.publicationTime,
                voteScore: commentData.voteScore,
                content: commentData.content,
              ),
            )
            .toList();

        final expectedComments = <CommentDetails>[];

        for (var i = 0; i < numberComments; i++) {
          final commentData = commentsData[i];
          final owner = owners[i % numberOwners];

          await commentRepository.addComment(
            postId,
            commentData,
          );

          final comment = CommentDetails.from(commentData, owner.data);

          expectedComments.add(comment);
        }

        final actualComments =
            await container.read(commentViewModelProvider.future);

        // Check that all the comments are present
        expect(actualComments, unorderedEquals(expectedComments));

        // Check that the comments are sorted from the newest to the oldest
        for (var i = 0; i < actualComments.length - 1; i++) {
          final currentComment = actualComments[i];
          final nextComment = actualComments[i + 1];

          expect(
            currentComment.publicationDate.isAfter(nextComment.publicationDate),
            isTrue,
          );
        }
      });
    });

    group("refresh logic", () {
      test("refresh shows newly added comment", () async {
        // We force the build of the view model to compute the initial state
        await container.read(commentViewModelProvider.future);

        // Then a comment is added
        final owner = FirestoreUserGenerator.generateUserFirestore(1).first;
        await userRepository.setUser(owner.uid, owner.data);

        final commentData =
            commentDataGenerator.createMockCommentData(ownerId: owner.uid);
        await commentRepository.addComment(
          postId,
          commentData,
        );

        // Before the refresh, there should be no comments when re-reading
        final comments = await container.read(commentViewModelProvider.future);

        expect(comments, isEmpty);

        // The user refreshes the comments
        await container.read(commentViewModelProvider.notifier).refresh();

        final expectedComment = CommentDetails.from(
          commentData,
          owner.data,
        );

        // The user should see the newly added comment
        final actualComments =
            await container.read(commentViewModelProvider.future);

        expect(actualComments, equals([expectedComment]));
      });
    });
  });
}
