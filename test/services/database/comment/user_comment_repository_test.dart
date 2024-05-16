import "package:cloud_firestore/cloud_firestore.dart";
import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/models/database/user_comment/user_comment_data.dart";
import "package:proxima/models/database/user_comment/user_comment_firestore.dart";
import "package:proxima/services/database/comment/user_comment_repository_service.dart";

import "../../../mocks/data/firestore_user.dart";
import "../../../mocks/data/firestore_user_comment.dart";

void main() {
  group("Testing user comments repository", () {
    late FakeFirebaseFirestore fakeFirestore;
    late UserCommentRepositoryService userCommentRepository;

    late UserFirestore user;
    late UserCommentFirestoreGenerator userCommentGenerator;
    late CollectionReference<Map<String, dynamic>> userCommentsCollection;

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();

      userCommentRepository = UserCommentRepositoryService(
        firestore: fakeFirestore,
      );

      user = (await FirestoreUserGenerator.addUsers(fakeFirestore, 1)).first;

      userCommentGenerator = UserCommentFirestoreGenerator();
      userCommentsCollection = fakeFirestore
          .collection(UserFirestore.collectionName)
          .doc(user.uid.value)
          .collection(UserCommentFirestore.userCommentSubCollectionName);
    });

    group("getting user comments", () {
      test("should return an empty list if the user has no comments", () async {
        final userComments =
            await userCommentRepository.getUserComments(user.uid);

        expect(userComments, isEmpty);
      });

      test("should return the user's comments", () async {
        final userComments = await userCommentGenerator.addComments(
          3,
          user.uid,
          userCommentRepository,
        );

        final fetchedUserComments =
            await userCommentRepository.getUserComments(user.uid);

        expect(fetchedUserComments, unorderedEquals(userComments));
      });

      test("should throw an error if a document has missing fields", () async {
        final userComment = await userCommentGenerator.addComment(
          user.uid,
          userCommentRepository,
        );

        // Delete the comment content field
        await userCommentsCollection
            .doc(userComment.id.value)
            .update({UserCommentData.contentField: FieldValue.delete()});

        expect(
          () => userCommentRepository.getUserComments(user.uid),
          throwsA(isA<Exception>()),
        );
      });
    });

    group("adding user comments", () {
      test("should add a user comment", () async {
        final userComment = userCommentGenerator.createMockUserComment();

        // Add the user comment
        await userCommentRepository.addUserComment(
          user.uid,
          userComment,
        );

        final fetchedUserComments =
            await userCommentRepository.getUserComments(user.uid);

        expect(fetchedUserComments, [userComment]);
      });
    });

    group("deleting user comments", () {
      test("should delete user comment when they are multiple comments",
          () async {
        final userComments = await userCommentGenerator.addComments(
          3,
          user.uid,
          userCommentRepository,
        );

        // Check if the comments were added
        final beforeDeleteUserComments =
            await userCommentRepository.getUserComments(user.uid);

        expect(beforeDeleteUserComments, userComments);

        final commentToDelete = userComments.first;

        // Delete the comment
        final batch = fakeFirestore.batch();

        userCommentRepository.deleteUserComment(
          user.uid,
          commentToDelete.id,
          batch,
        );

        await batch.commit();

        // Check if the comment was deleted
        final expectedComments =
            userComments.where((element) => element != commentToDelete);

        final afterDeleteUserComments =
            await userCommentRepository.getUserComments(user.uid);

        expect(
          afterDeleteUserComments,
          unorderedEquals(expectedComments),
        );
      });
    });
  });
}
