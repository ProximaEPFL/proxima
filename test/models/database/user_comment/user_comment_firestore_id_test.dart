import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/database/user_comment/user_comment_id_firestore.dart";

void main() {
  group("Testing user comment id firestore", () {
    test("hash overrides correctly", () {
      const id = "user_comment_id";
      const userCommentId = UserCommentIdFirestore(value: id);

      final expectedHash = id.hashCode;
      final actualHash = userCommentId.hashCode;
      expect(actualHash, expectedHash);
    });

    test("equality overrides correctly", () {
      const id = "user_comment_id";
      const userCommentId = UserCommentIdFirestore(value: id);

      const otherUserCommentId = UserCommentIdFirestore(value: id);
      expect(userCommentId, otherUserCommentId);
    });
  });
}
