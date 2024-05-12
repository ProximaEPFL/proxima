import "package:proxima/models/database/firestore/id_firestore.dart";

/// Represents the id of a comment from the user in Firestore.
/// /!\ This is not the same id as the id of a comment under a post. /!\
class UserCommentIdFirestore implements IdFirestore {
  @override
  final String value;

  const UserCommentIdFirestore({required this.value});

  @override
  bool operator ==(Object other) {
    return other is UserCommentIdFirestore && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}
