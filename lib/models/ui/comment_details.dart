import "package:flutter/foundation.dart";
import "package:proxima/models/database/comment/comment_data.dart";
import "package:proxima/models/database/user/user_firestore.dart";

@immutable
class CommentDetails {
  final String content;
  final String ownerDisplayName;
  final String ownerUsername;
  final int ownerCentauriPoints;
  final DateTime publicationDate;

  const CommentDetails({
    required this.content,
    required this.ownerDisplayName,
    required this.ownerUsername,
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
        other.ownerCentauriPoints == ownerCentauriPoints &&
        other.publicationDate == publicationDate;
  }

  @override
  int get hashCode {
    return Object.hash(
      content,
      ownerDisplayName,
      ownerUsername,
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
      ownerCentauriPoints: ownerData.centauriPoints,
      publicationDate: DateTime.fromMillisecondsSinceEpoch(
        commentData.publicationTime.millisecondsSinceEpoch,
      ),
    );
  }
}
