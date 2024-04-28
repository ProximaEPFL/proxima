// The comment id is strong typed to avoid misuse
import "package:flutter/foundation.dart";

@immutable
class CommentIdFirestore {
  final String value;

  const CommentIdFirestore({required this.value});

  @override
  bool operator ==(Object other) {
    return other is CommentIdFirestore && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}