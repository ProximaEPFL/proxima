import "package:cloud_firestore/cloud_firestore.dart";
import "package:proxima/models/database/comment/comment_id_firestore.dart";
import "package:proxima/models/database/user_comment/user_comment_data.dart";

/// This class represents a comment from the user in firestore.
class UserCommentFirestore {
  static const String userCommentSubCollectionName = "userComments";

  // The id of the referenced comment
  // This is also the id of the document in firestore
  final CommentIdFirestore id;

  final UserCommentData data;

  const UserCommentFirestore({
    required this.id,
    required this.data,
  });

  /// This method will create an instance of [UserCommentFirestore] from the
  /// document snapshot [docSnap] that comes from firestore
  factory UserCommentFirestore.fromDb(DocumentSnapshot docSnap) {
    if (!docSnap.exists) {
      throw Exception("User comment document does not exist");
    }

    final data = docSnap.data() as Map<String, dynamic>;

    return UserCommentFirestore(
      id: CommentIdFirestore(value: docSnap.id),
      data: UserCommentData.fromDbData(data),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserCommentFirestore &&
        other.id == id &&
        other.data == data;
  }

  @override
  int get hashCode => Object.hash(id, data);
}
