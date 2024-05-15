import "package:cloud_firestore/cloud_firestore.dart";
import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/models/database/user_comment/user_comment_data.dart";
import "package:proxima/models/database/user_comment/user_comment_firestore.dart";
import "package:proxima/services/database/firestore_service.dart";
import "package:proxima/services/database/user_comment_repository_service.dart";

import "../../mocks/data/firestore_user.dart";
import "../../mocks/data/firestore_user_comment.dart";

void main() {
  group("Testing user comments repository", () {
    late FakeFirebaseFirestore fakeFirestore;
    late UserCommentRepositoryService userCommentRepository;

    late UserFirestore user;
    late UserCommentFirestoreGenerator userCommentGenerator;
    late CollectionReference<Map<String, dynamic>> userCommentsCollection;

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();

      final container = ProviderContainer(
        overrides: [
          firestoreProvider.overrideWithValue(fakeFirestore),
        ],
      );

      userCommentRepository =
          container.read(userCommentRepositoryServiceProvider);

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
        final userComment = (await userCommentGenerator.addComments(
          1,
          user.uid,
          userCommentRepository,
        ))[0];

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
        await userCommentRepository.deleteUserComment(
          user.uid,
          commentToDelete.id,
        );

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
