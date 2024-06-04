import "package:flutter/foundation.dart";
import "package:proxima/models/database/comment/comment_data.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";

/// This class contains all the details of a comment
/// that are needed to display it in the UI.
@immutable
class CommentDetails {
  final String content;
  final String ownerDisplayName;
  final String ownerUsername;
  final UserIdFirestore ownerUserID;
  final int ownerCentauriPoints;
  final DateTime publicationDate;

  const CommentDetails({
    required this.content,
    required this.ownerDisplayName,
    required this.ownerUsername,
    required this.ownerUserID,
    required this.ownerCentauriPoints,
    required this.publicationDate,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CommentDetails &&
        other.content == content &&
        other.ownerDisplayName == ownerDisplayName &&
        other.ownerUsername == ownerUsername &&
        other.ownerUserID == ownerUserID &&
        other.ownerCentauriPoints == ownerCentauriPoints &&
        other.publicationDate == publicationDate;
  }

  @override
  int get hashCode {
    return Object.hash(
      content,
      ownerDisplayName,
      ownerUsername,
      ownerUserID,
      ownerCentauriPoints,
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
      ownerUsername: ownerData.username,
      ownerUserID: owner.uid,
      ownerCentauriPoints: ownerData.centauriPoints,
      publicationDate: DateTime.fromMillisecondsSinceEpoch(
        commentData.publicationTime.millisecondsSinceEpoch,
      ),
    );
  }
}
