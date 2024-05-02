import "package:flutter/foundation.dart";

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
}
