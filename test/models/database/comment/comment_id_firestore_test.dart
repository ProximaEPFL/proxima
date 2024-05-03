import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/database/comment/comment_id_firestore.dart";

void main() {
  group("Testing comment id firestore", () {
    test("hash overrides correctly", () {
      const id = "comment_id";
      const commentId = CommentIdFirestore(value: id);

      final expectedHash = id.hashCode;
      final actualHash = commentId.hashCode;
      expect(actualHash, expectedHash);
    });

    test("equality overrides correctly", () {
      const id = "comment_id";
      const commentId = CommentIdFirestore(value: id);

      const otherCommentId = CommentIdFirestore(value: id);
      expect(commentId, otherCommentId);
    });
  });
}
