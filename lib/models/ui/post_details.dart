import "package:flutter/foundation.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";

@immutable
class PostDetails {
  final PostIdFirestore postId;
  final String title;
  final String description;
  final int voteScore;
  final int commentNumber;
  final String ownerDisplayName;
  final int ownerCentauriPoints;
  final DateTime publicationDate;
  final int distance; // in meters
  final bool isChallenge;

  const PostDetails({
    required this.postId,
    required this.title,
    required this.description,
    required this.voteScore,
    required this.commentNumber,
    required this.ownerDisplayName,
    required this.ownerCentauriPoints,
    required this.publicationDate,
    required this.distance,
    this.isChallenge = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PostDetails &&
        other.postId == postId &&
        other.title == title &&
        other.description == description &&
        other.voteScore == voteScore &&
        other.commentNumber == commentNumber &&
        other.ownerDisplayName == ownerDisplayName &&
        other.ownerCentauriPoints == ownerCentauriPoints &&
        other.publicationDate == publicationDate &&
        other.distance == distance &&
        other.isChallenge == isChallenge;
  }

  @override
  int get hashCode {
    return Object.hash(
      postId,
      title,
      description,
      voteScore,
      commentNumber,
      ownerDisplayName,
      ownerCentauriPoints,
      publicationDate,
      distance,
      isChallenge,
    );
  }
}
