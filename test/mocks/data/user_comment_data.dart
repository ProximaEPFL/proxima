import "dart:math";

import "package:proxima/models/database/comment/comment_id_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/user_comment/user_comment_data.dart";

class UserCommentDataGenerator {
  final Random _random;

  UserCommentDataGenerator({int seed = 0}) : _random = Random(seed);

  List<UserCommentData> generateUserCommentData(int count) {
    return List.generate(count, (i) {
      return UserCommentData(
        parentPostId: PostIdFirestore(value: "parent_post_id_$i"),
        content: "content_$i",
        commentId: CommentIdFirestore(value: "comment_id_$i"),
      );
    });
  }

  UserCommentData createMockUserCommentData({
    PostIdFirestore? parentPostId,
    String? content,
    CommentIdFirestore? commentId,
  }) {
    return UserCommentData(
      parentPostId: parentPostId ??
          PostIdFirestore(value: "parent_post_id_${_random.nextInt(100)}"),
      content: content ?? "content_${_random.nextInt(100)}",
      commentId: commentId ??
          CommentIdFirestore(value: "comment_id_${_random.nextInt(100)}"),
    );
  }
}
