import "package:flutter/material.dart";
import "package:proxima/models/database/comment/comment_id_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/user_comment/user_comment_id_firestore.dart";

@immutable
class UserCommentDetails {
  final UserCommentIdFirestore userCommentId;
  final String description;
  final PostIdFirestore parentPostId;
  final CommentIdFirestore commentId;

  const UserCommentDetails({
    required this.commentId,
    required this.description,
    required this.parentPostId,
    required this.userCommentId,
  });

  @override
  bool operator ==(Object other) {
    return other is UserCommentDetails &&
        other.commentId == commentId &&
        other.description == description;
  }

  @override
  int get hashCode {
    return Object.hash(
      commentId,
      description,
    );
  }
}
