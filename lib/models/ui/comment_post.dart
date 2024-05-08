import "package:flutter/foundation.dart";
import "package:proxima/models/database/comment/comment_data.dart";
import "package:proxima/models/database/user/user_data.dart";

@immutable
class CommentPost {
  final String content;
  final String ownerDisplayName;
  final DateTime publicationDate;

  const CommentPost({
    required this.content,
    required this.ownerDisplayName,
    required this.publicationDate,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CommentPost &&
        other.content == content &&
        other.ownerDisplayName == ownerDisplayName &&
        other.publicationDate == publicationDate;
  }

  @override
  int get hashCode {
    return Object.hash(
      content,
      ownerDisplayName,
      publicationDate,
    );
  }

  /// Factory method to create a [CommentPost] from a [CommentData]
  /// and a [UserData] that represents the owner of the comment.
  /// (The one that wrote the comment)
  factory CommentPost.from(
    CommentData commentData,
    UserData ownerData,
  ) {
    return CommentPost(
      content: commentData.content,
      ownerDisplayName: ownerData.displayName,
      publicationDate: DateTime.fromMillisecondsSinceEpoch(
        commentData.publicationTime.millisecondsSinceEpoch,
      ),
    );
  }
}
