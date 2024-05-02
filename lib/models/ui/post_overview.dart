import "package:flutter/foundation.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";

@immutable
class PostOverview {
  final PostIdFirestore postId;
  final String title;
  final String description;
  final int voteScore;
  final int commentNumber;
  final String ownerDisplayName;
  final DateTime publicationDate;
  final int distance; // in meters

  const PostOverview({
    required this.postId,
    required this.title,
    required this.description,
    required this.voteScore,
    required this.commentNumber,
    required this.ownerDisplayName,
    required this.publicationDate,
    required this.distance,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PostOverview &&
        other.postId == postId &&
        other.title == title &&
        other.description == description &&
        other.voteScore == voteScore &&
        other.commentNumber == commentNumber &&
        other.ownerDisplayName == ownerDisplayName &&
        other.publicationDate == publicationDate &&
        other.distance == distance;
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
      publicationDate,
      distance,
    );
  }
}
