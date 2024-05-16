import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/database/comment/comment_id_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/models/database/user_comment/user_comment_data.dart";
import "package:proxima/models/database/user_comment/user_comment_firestore.dart";
import "package:proxima/services/database/user_comment_repository_service.dart";

import "user_comment_data.dart";

/// This class is responsible for generating mock [UserCommentFirestore] instances.
class UserCommentFirestoreGenerator {
  int _commentId = 0;
  final UserCommentDataGenerator _userCommentDataGenerator;

  UserCommentFirestoreGenerator({int seed = 0})
      : _userCommentDataGenerator = UserCommentDataGenerator(seed: seed);

  /// Add a comment for the user with id [userId]
  /// It will use the [userCommentRepository] to add the comment
  /// It returns the added comment
  Future<UserCommentFirestore> addComment(
    UserIdFirestore userId,
    UserCommentRepositoryService userCommentRepository,
  ) async {
    return (await addComments(1, userId, userCommentRepository)).first;
  }

  /// Add [number] of user comments for the user with id [userId] to the firestore database.
  /// It will use the [userCommentRepository] to add the comments.
  /// It will return the list of user comments that were added.
  Future<List<UserCommentFirestore>> addComments(
    int number,
    UserIdFirestore userId,
    UserCommentRepositoryService userCommentRepository,
  ) async {
    final userComments = List.generate(number, (_) => createMockUserComment());
    await Future.wait(
      userComments.map(
        (comment) => userCommentRepository.addUserComment(userId, comment),
      ),
    );
    return userComments;
  }

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
