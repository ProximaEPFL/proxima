import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/ui/user_post_details.dart";

void main() {
  group("User Post model testing", () {
    late DateTime publicationTime;

    setUp(() {
      publicationTime = DateTime.fromMillisecondsSinceEpoch(10000000);
    });

    test("hash overrides correctly", () {
      final userPost = UserPostDetails(
        postId: const PostIdFirestore(value: "post_1"),
        title: "title",
        description: "description",
        publicationTime: publicationTime,
      );

      final expectedHash = Object.hash(
        userPost.postId,
        userPost.title,
        userPost.description,
        userPost.publicationTime,
      );

      final actualHash = userPost.hashCode;

      expect(actualHash, expectedHash);
    });

    test("equality overrides correctly", () {
      final userPost = UserPostDetails(
        postId: const PostIdFirestore(value: "post_1"),
        title: "title",
        description: "description",
        publicationTime: publicationTime,
      );

      final userPostCopy = UserPostDetails(
        postId: const PostIdFirestore(value: "post_1"),
        title: "title",
        description: "description",
        publicationTime: publicationTime,
      );

      expect(userPost, userPostCopy);
    });

    test("inequality test on content", () {
      final userPost1 = UserPostDetails(
        postId: const PostIdFirestore(value: "post_1"),
        title: "title",
        description: "description 1",
        publicationTime: publicationTime,
      );

      final userPost2 = UserPostDetails(
        postId: const PostIdFirestore(value: "post_1"),
        title: "title",
        description: "description 2",
        publicationTime: publicationTime,
      );

      expect(userPost1 != userPost2, true);
    });
  });
}
