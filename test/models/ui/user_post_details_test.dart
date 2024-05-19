import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/ui/user_post_details.dart";

void main() {
  group("User Post model testing", () {
    test("hash overrides correctly", () {
      const userPost = UserPostDetails(
        postId: PostIdFirestore(value: "post_1"),
        title: "title",
        description: "description",
      );

      final expectedHash = Object.hash(
        userPost.postId,
        userPost.title,
        userPost.description,
      );

      final actualHash = userPost.hashCode;

      expect(actualHash, expectedHash);
    });

    test("equality overrides correctly", () {
      const userPost = UserPostDetails(
        postId: PostIdFirestore(value: "post_1"),
        title: "title",
        description: "description",
      );

      const userPostCopy = UserPostDetails(
        postId: PostIdFirestore(value: "post_1"),
        title: "title",
        description: "description",
      );

      expect(userPost, userPostCopy);
    });

    test("inequality test on content", () {
      const userPost1 = UserPostDetails(
        postId: PostIdFirestore(value: "post_1"),
        title: "title",
        description: "description 1",
      );

      const userPost2 = UserPostDetails(
        postId: PostIdFirestore(value: "post_1"),
        title: "title",
        description: "description 2",
      );

      expect(userPost1 != userPost2, true);
    });
  });
}
