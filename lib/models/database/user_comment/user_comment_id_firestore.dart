import "package:proxima/models/database/firestore/id_firestore.dart";

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
