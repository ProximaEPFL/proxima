import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/models/database/user_comment/user_comment_data.dart";
import "package:proxima/models/database/user_comment/user_comment_firestore.dart";
import "package:proxima/models/database/user_comment/user_comment_id_firestore.dart";
import "package:proxima/services/database/user_comment_repository_service.dart";

import "user_comment_data.dart";

class UserCommentFirestoreGenerator {
  int _userCommentId = 0;
  final UserCommentDataGenerator _userCommentDataGenerator;

  UserCommentFirestoreGenerator({int seed = 0})
      : _userCommentDataGenerator = UserCommentDataGenerator(seed: seed);

  Future<List<UserCommentFirestore>> addComments(
    int number,
    UserIdFirestore userId,
    UserCommentReposittoryService userCommentRepository,
  ) async {
    final userComments = <UserCommentFirestore>[];

    for (var i = 0; i < number; i++) {
      final userCommentData =
          _userCommentDataGenerator.createMockUserCommentData();
      final userCommentId =
          await userCommentRepository.addUserComment(userId, userCommentData);
      userComments
          .add(UserCommentFirestore(id: userCommentId, data: userCommentData));
    }

    return userComments;
  }

  UserCommentFirestore createMockUserComment({
    UserCommentIdFirestore? userCommentId,
    UserCommentData? data,
  }) {
    _userCommentId += 1;

    return UserCommentFirestore(
      id: userCommentId ??
          UserCommentIdFirestore(value: "userCommentId_$_userCommentId"),
      data: data ?? _userCommentDataGenerator.createMockUserCommentData(),
    );
  }
}
