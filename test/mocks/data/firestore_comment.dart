import "package:proxima/models/database/comment/comment_data.dart";
import "package:proxima/models/database/comment/comment_firestore.dart";
import "package:proxima/models/database/comment/comment_id_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/user_comment/user_comment_data.dart";
import "package:proxima/models/database/user_comment/user_comment_firestore.dart";
import "package:proxima/services/database/comment/comment_repository_service.dart";

import "comment_data.dart";

class CommentFirestoreGenerator {
  int _commentId = 0;
  final CommentDataGenerator _commentDataGenerator;

  CommentFirestoreGenerator({int seed = 0})
      : _commentDataGenerator = CommentDataGenerator(seed: seed);

  Future<(List<CommentFirestore>, List<UserCommentFirestore>)> addComments(
    int number,
    PostIdFirestore postId,
    CommentRepositoryService commentRepository,
  ) async {
    final postComments = <CommentFirestore>[];
    final userComments = <UserCommentFirestore>[];

    for (var i = 0; i < number; i++) {
      final commentData = _commentDataGenerator.createMockCommentData();
      final commentId = await commentRepository.addComment(postId, commentData);
      postComments.add(CommentFirestore(id: commentId, data: commentData));

      final userCommentData =
          UserCommentData(parentPostId: postId, content: commentData.content);
      final userComment =
          UserCommentFirestore(id: commentId, data: userCommentData);
      userComments.add(userComment);
    }

    return (postComments, userComments);
  }

  CommentFirestore createMockComment({
    CommentIdFirestore? commentId,
    CommentData? data,
  }) {
    _commentId += 1;

    return CommentFirestore(
      id: commentId ?? CommentIdFirestore(value: "commentId_$_commentId"),
      data: data ?? _commentDataGenerator.createMockCommentData(),
    );
  }
}
