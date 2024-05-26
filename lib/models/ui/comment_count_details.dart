import "package:flutter/material.dart";

@immutable

/// This class represents the details to display a comment count/icon on the post card.
class CommentCountDetails {
  final int count;
  final bool isIconBlue;

  const CommentCountDetails({
    required this.count,
    required this.isIconBlue,
  });

  @override
  bool operator ==(Object other) {
    return other is CommentCountDetails &&
        other.count == count &&
        other.isIconBlue == isIconBlue;
  }

  @override
  int get hashCode {
    return Object.hash(
      count,
      isIconBlue,
    );
  }
}
