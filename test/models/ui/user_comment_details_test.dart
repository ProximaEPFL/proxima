import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/database/comment/comment_id_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/user_comment/user_comment_id_firestore.dart";
import "package:proxima/models/ui/user_comment_details.dart";

void main() {
  group("User comment model testing", () {
    test("Hash overrides correctly", () {
      const userCommentDetails = UserCommentDetails(
        commentId: CommentIdFirestore(value: "comment1"),
        userCommentId: UserCommentIdFirestore(value: "userComment1"),
        description: "test comment",
        parentPostId: PostIdFirestore(value: "post1"),
      );

      final expectedHash = Object.hash(
        userCommentDetails.userCommentId,
        userCommentDetails.commentId,
        userCommentDetails.parentPostId,
        userCommentDetails.description,
      );

      final actualHash = userCommentDetails.hashCode;

      expect(actualHash, expectedHash);
    });

    test("Equality overrides correclty", () {
      const userCommentDetails = UserCommentDetails(
        commentId: CommentIdFirestore(value: "comment1"),
        userCommentId: UserCommentIdFirestore(value: "userComment1"),
        description: "test comment",
        parentPostId: PostIdFirestore(value: "post1"),
      );

      const userCommentDetailsCopy = UserCommentDetails(
        commentId: CommentIdFirestore(value: "comment1"),
        userCommentId: UserCommentIdFirestore(value: "userComment1"),
        description: "test comment",
        parentPostId: PostIdFirestore(value: "post1"),
      );

      expect(userCommentDetails, userCommentDetailsCopy);
    });

    test("Inequality test on content", () {
      const userCommentDetails1 = UserCommentDetails(
        commentId: CommentIdFirestore(value: "comment1"),
        userCommentId: UserCommentIdFirestore(value: "userComment1"),
        description: "test comment 1",
        parentPostId: PostIdFirestore(value: "post1"),
      );

      const userCommentDetails2 = UserCommentDetails(
        commentId: CommentIdFirestore(value: "comment1"),
        userCommentId: UserCommentIdFirestore(value: "userComment1"),
        description: "test comment 2",
        parentPostId: PostIdFirestore(value: "post1"),
      );

      expect(userCommentDetails1 != userCommentDetails2, true);
    });
  });
}
