import "package:flutter/material.dart";
import "package:proxima/models/database/comment/comment_id_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";

@immutable
class UserCommentDetails {
  final CommentIdFirestore commentId;
  final PostIdFirestore parentPostId;
  final String description;

  const UserCommentDetails({
    required this.commentId,
    required this.parentPostId,
    required this.description,
  });

  @override
  bool operator ==(Object other) {
    return other is UserCommentDetails &&
        other.commentId == commentId &&
        other.parentPostId == parentPostId &&
        other.description == description;
  }

  @override
  int get hashCode {
    return Object.hash(
      commentId,
      parentPostId,
      description,
    );
  }
}
