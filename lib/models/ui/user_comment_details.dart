import "package:flutter/material.dart";
import "package:proxima/models/database/user_comment/user_comment_id_firestore.dart";

@immutable
class UserCommentDetails {
  final UserCommentIdFirestore commentId;
  final String description;

  const UserCommentDetails({
    required this.commentId,
    required this.description,
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
