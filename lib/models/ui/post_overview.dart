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

  const PostOverview({
    required this.postId,
    required this.title,
    required this.description,
    required this.voteScore,
    required this.commentNumber,
    required this.ownerDisplayName,
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
        other.ownerDisplayName == ownerDisplayName;
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
    );
  }
}
