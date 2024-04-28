import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/database/comment/comment_firestore.dart";

import "../../../mocks/data/firestore_comment.dart";

void main() {
  group("Testing comment firestore", () {
    test("hash overrides correctly", () {
      final commentFirestore =
          CommentFirestoreGenerator().createRandomComment();

      final expectedHash =
          Object.hash(commentFirestore.id, commentFirestore.data);

      final actualHash = commentFirestore.hashCode;

      expect(actualHash, expectedHash);
    });

    test("equality overrides correctly", () {
      final commentFirestore =
          CommentFirestoreGenerator().createRandomComment();

      final otherCommentFirestore = CommentFirestore(
        id: commentFirestore.id,
        data: commentFirestore.data,
      );

      expect(commentFirestore, otherCommentFirestore);
    });
  });
}
