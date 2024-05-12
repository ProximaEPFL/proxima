import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/database/user_comment/user_comment_firestore.dart";

import "../../../mocks/data/firestore.dart";
import "../../../mocks/data/firestore_user_comment.dart";

void main() {
  group("Testing user comment firestore", () {
    late UserCommentFirestoreGenerator userCommentGenerator;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() async {
      userCommentGenerator = UserCommentFirestoreGenerator();
      fakeFirestore = FakeFirebaseFirestore();
    });

    test("hash overrides correctly", () {
      final userComment = userCommentGenerator.createMockUserComment();

      final expectedHash = Object.hash(userComment.id, userComment.data);
      final actualHash = userComment.hashCode;
      expect(actualHash, expectedHash);
    });

    test("equality overrides correctly", () {
      final userComment = userCommentGenerator.createMockUserComment();

      final otherUserComment = UserCommentFirestore(
        id: userComment.id,
        data: userComment.data,
      );
      expect(userComment, otherUserComment);
    });

    test("fromDb throw error when document doesn't exist", () async {
      final nonExistingDocSnap =
          await FirestoreGenerator.getNonExistingDocSnapshot(fakeFirestore);

      expect(
        () => UserCommentFirestore.fromDb(nonExistingDocSnap),
        throwsA(isA<Exception>()),
      );
    });
  });
}
