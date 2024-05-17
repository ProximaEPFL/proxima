import "package:cloud_firestore/cloud_firestore.dart";
import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/models/ui/validation/new_comment_validation.dart";
import "package:proxima/services/database/comment/comment_repository_service.dart";
import "package:proxima/services/database/firestore_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";
import "package:proxima/viewmodels/new_comment_view_model.dart";

import "../mocks/data/comment_data.dart";
import "../mocks/data/firestore_post.dart";
import "../mocks/data/firestore_user.dart";
import "../mocks/data/geopoint.dart";

void main() {
  group("Testing new comment view model", () {
    late FakeFirebaseFirestore fakeFirestore;
    late CommentDataGenerator commentDataGenerator;

    late CommentRepositoryService commentRepository;
    late AsyncNotifierFamilyProvider<NewCommentViewModel, NewCommentValidation,
        PostIdFirestore> newCommentViewModelPostProvider;

    late ProviderContainer container;

    late PostIdFirestore postId;
    late UserIdFirestore userId;

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      commentDataGenerator = CommentDataGenerator();
      userId = testingUserFirestoreId;

      container = ProviderContainer(
        overrides: [
          firestoreProvider.overrideWithValue(fakeFirestore),
          loggedInUserIdProvider.overrideWithValue(userId),
        ],
      );

      commentRepository = container.read(commentRepositoryServiceProvider);

      // Add a post to the database on which the comments will be added
      final post = FirestorePostGenerator().generatePostAt(userPosition0);
      await setPostFirestore(post, fakeFirestore);
      postId = post.id;

      newCommentViewModelPostProvider = newCommentViewModelProvider(postId);
    });

    test("Add a valid comment and reset correctly", () async {
      final validContent = commentDataGenerator.createMockCommentData().content;

      final newCommentViewModel =
          container.read(newCommentViewModelPostProvider.notifier);

      // Check the state before adding the comment
      final stateBeforeAdd = await newCommentViewModel.future;
      expect(
        stateBeforeAdd,
        NewCommentValidation(contentError: null, posted: false),
      );

      // Add the comment
      final timeBeforeAdd = Timestamp.now();
      final addResult = await newCommentViewModel.tryAddComment(validContent);
      final timeAfterAdd = Timestamp.now();

      expect(addResult, isTrue);

      // Get the comments
      final comments = await commentRepository.getPostComments(postId);

      expect(comments, hasLength(1));

      final comment = comments.first;

      expect(comment.data.content, validContent);
      expect(comment.data.ownerId, userId);

      // Check the publication time is between the timeBeforeAdd and timeAfterAdd
      expect(
        comment.data.publicationTime.microsecondsSinceEpoch,
        greaterThanOrEqualTo(timeBeforeAdd.microsecondsSinceEpoch),
      );
      expect(
        comment.data.publicationTime.microsecondsSinceEpoch,
        lessThanOrEqualTo(timeAfterAdd.microsecondsSinceEpoch),
      );

      // Check the state after adding the comment
      final stateAfterAdd = await newCommentViewModel.future;
      expect(
        stateAfterAdd,
        NewCommentValidation(contentError: null, posted: true),
      );

      // Reset the state
      await newCommentViewModel.reset();

      // Check the state after resetting
      final stateAfterReset = await newCommentViewModel.future;
      expect(
        stateAfterReset,
        NewCommentValidation(contentError: null, posted: false),
      );
    });

    test("Add an empty comment exposes error message", () async {
      const invalidContent = "";

      final newCommentViewModel =
          container.read(newCommentViewModelPostProvider.notifier);

      // Check the state before adding the comment
      final stateBeforeAdd = await newCommentViewModel.future;
      expect(
        stateBeforeAdd,
        NewCommentValidation(contentError: null, posted: false),
      );

      // Add the comment
      final addResult = await newCommentViewModel.tryAddComment(invalidContent);

      expect(addResult, isFalse);

      // Check the state after adding the comment
      final stateAfterAdd = await newCommentViewModel.future;
      expect(
        stateAfterAdd,
        NewCommentValidation(
          contentError: NewCommentViewModel.contentEmptyError,
          posted: false,
        ),
      );
    });

    test("Add a comment without being logged in expose error async state",
        () async {
      final validContent = commentDataGenerator.createMockCommentData().content;

      final newCommentViewModel =
          container.read(newCommentViewModelPostProvider.notifier);

      container.updateOverrides([
        firestoreProvider.overrideWithValue(fakeFirestore),
        loggedInUserIdProvider.overrideWithValue(null),
      ]);

      final addResult = await newCommentViewModel.tryAddComment(validContent);
      expect(addResult, isFalse);

      expect(
        () async => await newCommentViewModel.future,
        throwsA(isA<Exception>()),
      );
    });
  });
}
