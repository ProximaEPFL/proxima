import "package:proxima/models/database/comment/comment_id_firestore.dart";
import "package:proxima/models/database/user_comment/user_comment_data.dart";
import "package:proxima/models/database/user_comment/user_comment_firestore.dart";

import "user_comment_data.dart";

/// This class is responsible for generating mock [UserCommentFirestore] instances.
class UserCommentFirestoreGenerator {
  int _commentId = 0;
  final UserCommentDataGenerator _userCommentDataGenerator;

  UserCommentFirestoreGenerator({int seed = 0})
      : _userCommentDataGenerator = UserCommentDataGenerator(seed: seed);

  /// Create a random mock [UserCommentFirestore] instance.
  /// The [commentId] and [data] can be provided to avoid randomness.
  UserCommentFirestore createMockUserComment({
    CommentIdFirestore? commentId,
    UserCommentData? data,
  }) {
    _commentId += 1;

    return UserCommentFirestore(
      id: commentId ?? CommentIdFirestore(value: "commentId_$_commentId"),
      data: data ?? _userCommentDataGenerator.generateUserCommentData(),
    );
  }
}
