import "package:cloud_firestore/cloud_firestore.dart";
import "package:proxima/models/database/user_comment/user_comment_data.dart";
import "package:proxima/models/database/user_comment/user_comment_id_firestore.dart";

/// This class represent a comment that the user made on a post with id [parentPostId].
class UserCommentFirestore {
  static const String userCommentSubCollectionName = "userComments";

  // The id of the firestore document that keeps the reference to the comment.
  // Not the id of the comment itself.
  final UserCommentIdFirestore id;

  final UserCommentData data;

  UserCommentFirestore({
    required this.id,
    required this.data,
  });

  /// This method will create an instance of [UserCommentFirestore] from the
  /// document snapshot [docSnap] that comes from firestore
  factory UserCommentFirestore.fromDb(DocumentSnapshot docSnap) {
    if (!docSnap.exists) {
      throw Exception("User comment document does not exist");
    }

    try {
      final data = docSnap.data() as Map<String, dynamic>;

      return UserCommentFirestore(
        id: UserCommentIdFirestore(value: docSnap.id),
        data: UserCommentData.fromDbData(data),
      );
    } catch (e) {
      if (e is TypeError) {
        throw FormatException(
            "Cannot parse user comment document: ${e.toString()}");
      } else {
        rethrow;
      }
    }
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
