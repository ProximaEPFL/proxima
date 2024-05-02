import "package:proxima/models/database/comment/comment_data.dart";
import "package:proxima/models/database/comment/comment_firestore.dart";
import "package:proxima/models/database/comment/comment_id_firestore.dart";

import "comment_data.dart";

class CommentFirestoreGenerator {
  int _commentId = 0;
  final CommentDataGenerator _commentDataGenerator;

  CommentFirestoreGenerator({int seed = 0})
      : _commentDataGenerator = CommentDataGenerator(seed: seed);

  CommentFirestore createMockComment({
    CommentIdFirestore? commentId,
    CommentData? data,
  }) {
    _commentId += 1;

    return CommentFirestore(
      id: commentId ?? CommentIdFirestore(value: "commentId_$_commentId"),
      data: data ?? _commentDataGenerator.createRandomCommentData(),
    );
  }
}
