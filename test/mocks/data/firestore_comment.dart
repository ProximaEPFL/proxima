import "package:proxima/models/database/comment/comment_firestore.dart";
import "package:proxima/models/database/comment/comment_id_firestore.dart";

import "comment_data.dart";

class CommentFirestoreGenerator {
  int _commentId = 0;

  CommentFirestore createRandomComment() {
    _commentId += 1;

    return CommentFirestore(
      id: CommentIdFirestore(value: "commentId_$_commentId"),
      data: CommentDataGenerator.createRandomCommentData(),
    );
  }
}
