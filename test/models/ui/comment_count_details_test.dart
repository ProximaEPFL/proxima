import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/ui/comment_count_details.dart";

void main() {
  group("Testing comment count details", () {
    late CommentCountDetails comment;

    setUp(() {
      comment = const CommentCountDetails(count: 1324, isIconBlue: true);
    });

    test("hash overrides correctly", () {
      final actualHash = comment.hashCode;

      final expectedHash = Object.hash(
        comment.count,
        comment.isIconBlue,
      );

      expect(actualHash, expectedHash);
    });

    test("equality overrides correctly", () {
      final commentCopy = CommentCountDetails(
        count: comment.count,
        isIconBlue: comment.isIconBlue,
      );

      expect(comment, commentCopy);
    });
  });
}
