import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/database/comment/comment_id_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/models/database/user_comment/user_comment_data.dart";
import "package:proxima/models/database/user_comment/user_comment_firestore.dart";
import "package:proxima/services/database/user_comment_repository_service.dart";

import "user_comment_data.dart";

class UserCommentFirestoreGenerator {
  int _commentId = 0;
  final UserCommentDataGenerator _userCommentDataGenerator;

  UserCommentFirestoreGenerator({int seed = 0})
      : _userCommentDataGenerator = UserCommentDataGenerator(seed: seed);

  Future<List<UserCommentFirestore>> addComments(
    int number,
    UserIdFirestore userId,
    UserCommentRepositoryService userCommentRepository,
  ) async {
    final userComments = <UserCommentFirestore>[];

    for (var i = 0; i < number; i++) {
      final userComment = createMockUserComment();
      userComments.add(
        UserCommentFirestore(id: userComment.id, data: userComment.data),
      );

      await userCommentRepository.addUserComment(userId, userComments.last);
    }

    return userComments;
  }

  UserCommentFirestore createMockUserComment({
    CommentIdFirestore? userCommentId,
    UserCommentData? data,
  }) {
    _commentId += 1;

    return UserCommentFirestore(
      id: userCommentId ??
          CommentIdFirestore(value: "userCommentId_$_commentId"),
      data: data ?? _userCommentDataGenerator.createMockUserCommentData(),
    );
  }
}
