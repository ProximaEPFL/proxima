import "package:proxima/models/database/comment/comment_data.dart";
import "package:proxima/models/database/comment/comment_firestore.dart";
import "package:proxima/models/database/comment/comment_id_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/services/database/comment/post_comment_repository_service.dart";

import "comment_data.dart";

class CommentFirestoreGenerator {
  int _commentId = 0;
  final CommentDataGenerator _commentDataGenerator;

  CommentFirestoreGenerator({int seed = 0})
      : _commentDataGenerator = CommentDataGenerator(seed: seed);

  Future<List<CommentFirestore>> addComments(
    int number,
    PostIdFirestore postId,
    PostCommentRepositoryService commentRepository,
  ) async {
    final comments = <CommentFirestore>[];

    for (var i = 0; i < number; i++) {
      final commentData = _commentDataGenerator.createMockCommentData();
      final commentId = await commentRepository.addComment(postId, commentData);
      comments.add(CommentFirestore(id: commentId, data: commentData));
    }

    return comments;
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
