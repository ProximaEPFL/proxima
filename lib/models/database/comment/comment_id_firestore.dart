import "package:flutter/foundation.dart";
import "package:proxima/models/database/firestore/id_firestore.dart";

/// The comment id is strong typed to avoid misuse
@immutable
class CommentIdFirestore implements IdFirestore {
  @override
  final String value;

  const CommentIdFirestore({required this.value});

  @override
  bool operator ==(Object other) {
    return other is CommentIdFirestore && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}
