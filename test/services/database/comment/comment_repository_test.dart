import "package:cloud_firestore/cloud_firestore.dart";
import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/comment/comment_firestore.dart";
import "package:proxima/models/database/comment/comment_id_firestore.dart";
import "package:proxima/models/database/post/post_data.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/services/database/comment/comment_repository_service.dart";
import "package:proxima/services/database/firestore_service.dart";

import "../../../mocks/data/comment_data.dart";
import "../../../mocks/data/firestore_comment.dart";
import "../../../mocks/data/firestore_post.dart";
import "../../../mocks/data/firestore_user.dart";
import "../../../mocks/data/geopoint.dart";

void main() {
  group("Testing comment repository", () {
    late FakeFirebaseFirestore fakeFirestore;

    late CommentRepositoryService commentRepo;

    late PostFirestore post; // the post we use to test
    late PostFirestore otherPost; // some other post
    late UserFirestore user; // the user we use to test
    late UserFirestore otherUser; // some other user

    late CommentFirestoreGenerator commentGenerator;
    late CommentDataGenerator postCommentDataGenerator;

    late DocumentReference<Map<String, dynamic>> postDocument;
    late CollectionReference<Map<String, dynamic>> postCommentCollection;

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();

      final container = ProviderContainer(
        overrides: [
          firestoreProvider.overrideWithValue(fakeFirestore),
        ],
      );

      commentRepo = container.read(commentRepositoryServiceProvider);

      final posts = await FirestorePostGenerator().addPosts(
        fakeFirestore,
        userPosition0,
        2,
      );
      post = posts.first;
      otherPost = posts.last;
      // All users have the same data, but this is ok.
      final users = posts
          .map(
            (post) =>
                UserFirestore(uid: post.data.ownerId, data: testingUserData),
          )
          .toList();
      await setUsersFirestore(fakeFirestore, users);
      user = users.first;
      otherUser = users.last;

      commentGenerator = CommentFirestoreGenerator();
      postCommentDataGenerator = CommentDataGenerator();

      postDocument = fakeFirestore
          .collection(PostFirestore.collectionName)
          .doc(post.id.value);
      postCommentCollection =
          postDocument.collection(CommentFirestore.subCollectionName);
    });

    group("getting post comments", () {
      test("should get the comments under a post", () async {
        final (postComments, _) = await commentGenerator.addComments(
          3,
          post.id,
          commentRepo,
        );
        // Add comments under the other post
        await commentGenerator.addComments(
          3,
          otherPost.id,
          commentRepo,
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
        final (_, userComments) = await commentGenerator.addCommentsForUser(
          3,
          user.uid,
          commentRepo,
          fakeFirestore,
        );
        // Add comments made by the other user
        await commentGenerator.addCommentsForUser(
          3,
          otherUser.uid,
          commentRepo,
          fakeFirestore,
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
      test("should add comments", () async {
        final (postCommentUser0Post0, userCommentUser0Post0) =
            await commentGenerator.addComment(post.id, user.uid, commentRepo);
        final (_, userCommentUser0Post1) = await commentGenerator.addComment(
          otherPost.id,
          user.uid,
          commentRepo,
        );
        final (postCommentUser1Post0, _) = await commentGenerator.addComment(
          post.id,
          otherUser.uid,
          commentRepo,
        );
        await commentGenerator.addComment(
          otherPost.id,
          otherUser.uid,
          commentRepo,
        );

        // Check the post comments are correct
        final expectedPostComments = [
          postCommentUser0Post0,
          postCommentUser1Post0,
        ];
        final actualPostComments = await commentRepo.getPostComments(post.id);
        expect(actualPostComments, unorderedEquals(expectedPostComments));

        // Check the user comments are correct
        final expectedUserComments = [
          userCommentUser0Post0,
          userCommentUser0Post1,
        ];
        final actualUserComments = await commentRepo.getUserComments(user.uid);
        expect(actualUserComments, unorderedEquals(expectedUserComments));
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

    /// Utility function to add comments for multiple users
    /// This will create [nbUsers] users and add a comment for each of them
    /// to the [post].
    Future<(List<UserFirestore>, List<CommentFirestore>)> addCommentsForUsers(
      int nbUsers,
    ) async {
      final users =
          await FirestoreUserGenerator.addUsers(fakeFirestore, nbUsers);
      final postComments = <CommentFirestore>[];

      for (user in users) {
        final (comment, _) = await commentGenerator.addComment(
          post.id,
          user.uid,
          commentRepo,
        );

        postComments.add(comment);
      }

      // Check that the user comments have been added
      for (user in users) {
        final userComments = await commentRepo.getUserComments(user.uid);

        expect(userComments, isNotEmpty);
      }

      return (users, postComments);
    }

    group("deleting comments", () {
      test(
        "should delete a comment when there are multiple comments",
        () async {
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
        },
      );

      test(
          "should thrown an error and do nothing if the comment does not exist",
          () async {
        final (expectedComments, _) =
            await commentGenerator.addComments(5, post.id, commentRepo);

        const commentId = CommentIdFirestore(value: "non_existent_comment_id");

        expect(
          () async => await commentRepo.deleteComment(
            post.id,
            commentId,
            testingUserFirestoreId,
          ),
          throwsA(isA<Exception>()),
        );

        // Check that no comments were deleted
        final actualComments = await commentRepo.getPostComments(post.id);
        expect(actualComments, unorderedEquals(expectedComments));

        // Check that the comment count was not updated
        final postDoc = await postDocument.get();
        final commentCount = PostFirestore.fromDb(postDoc).data.commentCount;
        expect(commentCount, equals(5));
      });
    });

    group("deleting all comments", () {
      test("should delete all the comments", () async {
        const nbUsers = 5;
        late List<UserFirestore> users;

        // All users have a comment under the post
        (users, _) = await addCommentsForUsers(nbUsers);
        // The first user has a post in the other post
        final (_, expectedFirstUserComment) = await commentGenerator.addComment(
          otherPost.id,
          users.first.uid,
          commentRepo,
        );

        final firstUserComments = await commentRepo.getUserComments(
          users.first.uid,
        );
        expect(firstUserComments, hasLength(2));

        final batch = fakeFirestore.batch();
        await commentRepo.deleteAllComments(post.id, batch);
        await batch.commit();

        // Check that all the comments were deleted
        final actualPostComments = await commentRepo.getPostComments(post.id);
        expect(actualPostComments, isEmpty);

        // The first user is the only one with a comment left
        final actualFirstUserComments = await commentRepo.getUserComments(
          users.first.uid,
        );
        expect(actualFirstUserComments, equals([expectedFirstUserComment]));

        for (user in users.skip(1)) {
          final userComments = await commentRepo.getUserComments(user.uid);
          expect(userComments, isEmpty);
        }
      });
    });
  });
}
