import "package:flutter/foundation.dart";
import "package:proxima/models/database/comment/comment_data.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";

@immutable
class CommentDetails {
  final String content;
  final String ownerDisplayName;
  final UserIdFirestore ownerUid;
  final DateTime publicationDate;

  const CommentDetails({
    required this.content,
    required this.ownerDisplayName,
    required this.ownerUid,
    required this.publicationDate,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CommentDetails &&
        other.content == content &&
        other.ownerDisplayName == ownerDisplayName &&
        other.ownerUid == ownerUid &&
        other.publicationDate == publicationDate;
  }

  @override
  int get hashCode {
    return Object.hash(
      content,
      ownerDisplayName,
      ownerUid,
      publicationDate,
    );
  }

  /// Factory method to create a [CommentDetails] from a [CommentData]
  /// and a [UserFirestore] that represents the owner of the comment.
  /// (The one that wrote the comment)
  factory CommentDetails.from(
    CommentData commentData,
    UserFirestore owner,
  ) {
    final ownerData = owner.data;
    return CommentDetails(
      content: commentData.content,
      ownerDisplayName: ownerData.displayName,
      ownerUid: owner.uid,
      publicationDate: DateTime.fromMillisecondsSinceEpoch(
        commentData.publicationTime.millisecondsSinceEpoch,
      ),
    );
  }
}
