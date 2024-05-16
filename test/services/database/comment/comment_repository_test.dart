import "package:cloud_firestore/cloud_firestore.dart";
import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/comment/comment_firestore.dart";
import "package:proxima/models/database/post/post_data.dart";
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

    late DocumentReference<Map<String, dynamic>> postDocument;
    late CollectionReference<Map<String, dynamic>> postCommentCollection;

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

      user = await FirestoreUserGenerator.addUser(fakeFirestore);
      post = FirestorePostGenerator().createUserPost(user.uid, userPosition0);
      await setPostFirestore(post, fakeFirestore);

      postCommentGenerator = CommentFirestoreGenerator();
      postCommentDataGenerator = CommentDataGenerator();

      userCommentGenerator = UserCommentFirestoreGenerator();

      postDocument = fakeFirestore
          .collection(PostFirestore.collectionName)
          .doc(post.id.value);
      postCommentCollection =
          postDocument.collection(CommentFirestore.subCollectionName);
    });

    group("getting post comments", () {
      test("should get the comments under a post", () async {
        final postComments = await postCommentGenerator.addComments(
          3,
          post.id,
          postCommentRepo,
        );

        final actualComments = await commentRepo.getPostComments(post.id);

        expect(actualComments, unorderedEquals(postComments));
      });

      test("should return an empty list if there are no comments", () async {
        final comments = await commentRepo.getPostComments(post.id);

        expect(comments, isEmpty);
      });

      test("should throw an error if the comment has missing field", () async {
        await postCommentCollection.doc("comment_id").set({
          "missing_field": "missing_field",
        });

        expect(
          () async => await commentRepo.getPostComments(post.id),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group("getting user comments", () {
      test("should get the comments made by a user", () async {
        final userComments = await userCommentGenerator.addComments(
          3,
          user.uid,
          userCommentRepo,
        );

        final actualComments = await commentRepo.getUserComments(user.uid);

        expect(actualComments, unorderedEquals(userComments));
      });

      test("should return an empty list if the user has no comments", () async {
        final userComments = await commentRepo.getUserComments(user.uid);

        expect(userComments, isEmpty);
      });
    });

    group("adding comments", () {
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

      test(
          "should initialize the comment count of a post to 1 when the commentCount field doesn't exist and a post is added",
          () async {
        // Remove the comment count field
        await postDocument
            .update({PostData.commentCountField: FieldValue.delete()});

        final commentData = postCommentDataGenerator.createMockCommentData();

        await commentRepo.addComment(
          post.id,
          commentData,
        );

        // Check that the comment count was updated correctly
        final postDoc = await postDocument.get();
        final actualPost = PostFirestore.fromDb(postDoc);

        expect(actualPost.data.commentCount, equals(1));
      });
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

    Future<(List<UserFirestore>, List<CommentFirestore>)> addCommentsForUsers(
      int nbUsers,
    ) async {
      final users =
          await FirestoreUserGenerator.addUsers(fakeFirestore, nbUsers);
      final postComments = <CommentFirestore>[];

      for (user in users) {
        final commentData =
            postCommentDataGenerator.createMockCommentData(ownerId: user.uid);

        final commentId = await commentRepo.addComment(post.id, commentData);

        postComments.add(CommentFirestore(id: commentId, data: commentData));
      }

      // Check that the user comments have been added
      for (user in users) {
        final userComments = await commentRepo.getUserComments(user.uid);

        expect(userComments, isNotEmpty);
      }

      return (users, postComments);
    }

    group("deleting comments", () {
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

      test("should delete a comment when they are multiple comments", () async {
        const nbUsers = 5;
        late List<UserFirestore> users;
        late List<CommentFirestore> postComments;

        (users, postComments) = await addCommentsForUsers(nbUsers);

        // Delete the comment modulo 2
        for (final (i, user) in users.indexed) {
          final comment = postComments[i];

          if (i % 2 == 0) {
            await commentRepo.deleteComment(post.id, comment.id, user.uid);
          }
        }

        final actualPostComments = await commentRepo.getPostComments(post.id);

        // Check that the right user and post comments were deleted
        for (final (i, user) in users.indexed) {
          final userComments = await commentRepo.getUserComments(user.uid);
          final postComment = postComments[i];

          if (i % 2 == 0) {
            expect(userComments, isEmpty);
            expect(actualPostComments.contains(postComment), isFalse);
          } else {
            expect(userComments, isNotEmpty);
            expect(actualPostComments.contains(postComment), isTrue);
          }
        }
      });
    });

    group("deleting all comments", () {
      test("should delete all the comments", () async {
        const nbUsers = 5;
        late List<UserFirestore> users;

        (users, _) = await addCommentsForUsers(nbUsers);

        final batch = fakeFirestore.batch();
        await commentRepo.deleteAllComments(post.id, batch);
        await batch.commit();

        // Check that all the comments were deleted
        final actualPostComments = await commentRepo.getPostComments(post.id);
        expect(actualPostComments, isEmpty);

        for (user in users) {
          final userComments = await commentRepo.getUserComments(user.uid);
          expect(userComments, isEmpty);
        }
      });
    });
  });
}
