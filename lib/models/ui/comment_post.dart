import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/foundation.dart";

@immutable
class CommentPost {
  final String content;
  final String ownerDisplayName;
  final Timestamp publicationTime; //TODO: Give correct type

  const CommentPost({
    required this.content,
    required this.ownerDisplayName,
    required this.publicationTime,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CommentPost &&
        other.content == content &&
        other.ownerDisplayName == ownerDisplayName &&
        other.publicationTime == publicationTime;
  }

  @override
  int get hashCode {
    return Object.hash(
      content,
      ownerDisplayName,
      publicationTime,
    );
  }
}
