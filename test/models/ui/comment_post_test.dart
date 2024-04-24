import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/ui/comment_post.dart";

void main() {
  group("Comment Post testing", () {
    test("hash overrides correctly", () {
      const commentPost = CommentPost(
        content: "content",
        ownerDisplayName: "username",
      );

      final expectedHash = Object.hash(
        commentPost.content,
        commentPost.ownerDisplayName,
      );

      final actualHash = commentPost.hashCode;

      expect(actualHash, expectedHash);
    });

    test("equality overrides correctly", () {
      const commentPost = CommentPost(
        content: "content",
        ownerDisplayName: "username",
      );

      const commentPostCopy = CommentPost(
        content: "content",
        ownerDisplayName: "username",
      );

      expect(commentPost, commentPostCopy);
    });
  });
}
