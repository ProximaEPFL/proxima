import "package:flutter/foundation.dart";

@immutable
class CommentPost {
  final String content;
  final String ownerDisplayName;

  const CommentPost({
    required this.content,
    required this.ownerDisplayName,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CommentPost &&
        other.content == content &&
        other.ownerDisplayName == ownerDisplayName;
  }

  @override
  int get hashCode {
    return Object.hash(
      content,
      ownerDisplayName,
    );
  }
}
