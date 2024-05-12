import "package:cloud_firestore/cloud_firestore.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/models/database/user_comment/user_comment_data.dart";
import "package:proxima/models/database/user_comment/user_comment_firestore.dart";
import "package:proxima/models/database/user_comment/user_comment_id_firestore.dart";

/// This class is responsible for managing the user's comments in the firestore database.
/// This is the class to be used for displaying the user's comments on the profile page.
class UserCommentReposittoryService {
  final FirebaseFirestore _firestore;

  UserCommentReposittoryService({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  CollectionReference _userCommentCollection(UserIdFirestore userId) =>
      _firestore
          .collection(UserFirestore.collectionName)
          .doc(userId.value)
          .collection(UserCommentFirestore.userCommentSubCollectionName);

  /// Get the references to the user's comments.
  Future<List<UserCommentFirestore>> getUserComments(
    UserIdFirestore userId,
  ) async {
    final userCommentCollection = _userCommentCollection(userId);

    final userCommentQuery = await userCommentCollection.get();

    final userComments = userCommentQuery.docs
        .map((docSnap) => UserCommentFirestore.fromDb(docSnap))
        .toList();

    return userComments;
  }

  /// Add a reference [UserCommentData] in the user's document to keep
  /// track of the comment that the user made.
  Future<UserCommentIdFirestore> addUserComment(
    UserIdFirestore userId,
    UserCommentData userCommentData,
  ) async {
    final userCommentCollection = _userCommentCollection(userId);

    final docRef = await userCommentCollection.add(userCommentData.toDbData());

    return UserCommentIdFirestore(value: docRef.id);
  }

  /// Delete the reference to the comment that the user made.
  Future<void> deleteUserComment(
    UserIdFirestore userId,
    UserCommentIdFirestore userCommentId,
  ) {
    final userCommentCollection = _userCommentCollection(userId);

    return userCommentCollection.doc(userCommentId.value).delete();
  }
}
