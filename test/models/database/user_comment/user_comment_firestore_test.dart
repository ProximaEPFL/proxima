import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/database/user_comment/user_comment_firestore.dart";

import "../../../mocks/data/firestore.dart";
import "../../../mocks/data/firestore_user_comment.dart";

void main() {
  group("Testing user comment firestore", () {
    late UserCommentFirestoreGenerator userCommentGenerator;

    setUp(() async {
      userCommentGenerator = UserCommentFirestoreGenerator();
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
          await FirestoreGenerator.getNonExistingDocSnapshot();

      expect(
        () => UserCommentFirestore.fromDb(nonExistingDocSnap),
        throwsA(isA<Exception>()),
      );
    });
  });
}
