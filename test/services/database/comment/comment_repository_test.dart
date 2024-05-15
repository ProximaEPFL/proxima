import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/comment/comment_firestore.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/models/database/user_comment/user_comment_data.dart";
import "package:proxima/models/database/user_comment/user_comment_firestore.dart";
import "package:proxima/services/database/comment/comment_repository_service.dart";
import "package:proxima/services/database/comment/post_comment_repository_service.dart";
import "package:proxima/services/database/comment/user_comment_repository_service.dart";
import "package:proxima/services/database/firestore_service.dart";

import "../../../mocks/data/comment_data.dart";
import "../../../mocks/data/firestore_comment.dart";
import "../../../mocks/data/firestore_post.dart";
import "../../../mocks/data/firestore_user.dart";
import "../../../mocks/data/firestore_user_comment.dart";
import "../../../mocks/data/geopoint.dart";

void main() {
  group("Testing comment repository", () {
    late FakeFirebaseFirestore fakeFirestore;

    late PostCommentRepositoryService postCommentRepo;
    late UserCommentRepositoryService userCommentRepo;
    late CommentRepositoryService commentRepo;

    late UserFirestore user;
    late PostFirestore post;

    late CommentFirestoreGenerator postCommentGenerator;
    late CommentDataGenerator postCommentDataGenerator;

    late UserCommentFirestoreGenerator userCommentGenerator;

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();

      postCommentRepo = PostCommentRepositoryService(firestore: fakeFirestore);
      userCommentRepo = UserCommentRepositoryService(firestore: fakeFirestore);

      final container = ProviderContainer(
        overrides: [
          firestoreProvider.overrideWithValue(fakeFirestore),
        ],
      );

      commentRepo = container.read(commentRepositoryServiceProvider);

      user = (await FirestoreUserGenerator.addUsers(fakeFirestore, 1)).first;
      post = FirestorePostGenerator().createUserPost(user.uid, userPosition0);
      await setPostFirestore(post, fakeFirestore);

      postCommentGenerator = CommentFirestoreGenerator();
      postCommentDataGenerator = CommentDataGenerator();

      userCommentGenerator = UserCommentFirestoreGenerator();
    });

    test("should get the comments under a post", () async {
      final postComments = await postCommentGenerator.addComments(
        3,
        post.id,
        postCommentRepo,
      );

      final actualComments = await commentRepo.getPostComments(post.id);

      expect(actualComments, unorderedEquals(postComments));
    });

    test("should get the comments made by a user", () async {
      final userComments =
          await userCommentGenerator.addComments(3, user.uid, userCommentRepo);

      final actualComments = await commentRepo.getUserComments(user.uid);

      expect(actualComments, unorderedEquals(userComments));
    });

    test("should add a comment", () async {
      final commentData =
          postCommentDataGenerator.createMockCommentData(ownerId: user.uid);

      final commentId = await commentRepo.addComment(post.id, commentData);

      // Get the expected comment
      final expectedPostComment = CommentFirestore(
        id: commentId,
        data: commentData,
      );

      final expectedUserComment = UserCommentFirestore(
        id: commentId,
        data: UserCommentData(
          parentPostId: post.id,
          content: commentData.content,
        ),
      );

      // Get the actual comments
      final actualPostComments = await commentRepo.getPostComments(post.id);
      final actualUserComments = await commentRepo.getUserComments(user.uid);

      expect(actualPostComments, [expectedPostComment]);
      expect(actualUserComments, [expectedUserComment]);
    });

    /// Utility function to check that the post and user comments are not empty
    Future<void> checkPostAndUserCommentsNotEmpty() async {
      final postComments = await commentRepo.getPostComments(post.id);
      final userComments = await commentRepo.getUserComments(user.uid);

      expect(postComments, isNotEmpty);
      expect(userComments, isNotEmpty);
    }

    /// Utility function to check that the post and user comments are empty
    Future<void> checkPostAndUserCommentsEmpty() async {
      final postComments = await commentRepo.getPostComments(post.id);
      final userComments = await commentRepo.getUserComments(user.uid);

      expect(postComments, isEmpty);
      expect(userComments, isEmpty);
    }

    test("should delete a comment", () async {
      // Add a comment
      final commentData =
          postCommentDataGenerator.createMockCommentData(ownerId: user.uid);

      final commentId = await commentRepo.addComment(post.id, commentData);

      // Check that it was added correctly
      await checkPostAndUserCommentsNotEmpty();

      // Delete the comment
      await commentRepo.deleteComment(post.id, commentId, user.uid);

      // Check that it was deleted correctly
      await checkPostAndUserCommentsEmpty();
    });

    test("should delete all the comments", () async {
      // Add a comment
      final commentData =
          postCommentDataGenerator.createMockCommentData(ownerId: user.uid);

      await commentRepo.addComment(post.id, commentData);

      // Check that it was added correctly
      await checkPostAndUserCommentsNotEmpty();

      // Delete all the comments
      final batch = fakeFirestore.batch();
      await commentRepo.deleteAllComments(post.id, batch);
      await batch.commit();

      // Check that it was deleted correctly
      await checkPostAndUserCommentsEmpty();
    });
  });
}
