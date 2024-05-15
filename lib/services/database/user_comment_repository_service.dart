import "package:cloud_firestore/cloud_firestore.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/comment/comment_id_firestore.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/models/database/user_comment/user_comment_data.dart";
import "package:proxima/models/database/user_comment/user_comment_firestore.dart";
import "package:proxima/services/database/firestore_service.dart";

/// This class is responsible for managing the user's comments in the firestore database.
/// This is the class to be used for displaying the user's comments on the profile page.
class UserCommentRepositoryService {
  final FirebaseFirestore _firestore;

  UserCommentRepositoryService({
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
  Future<void> addUserComment(
    UserIdFirestore userId,
    UserCommentFirestore userComment,
  ) async {
    final userCommentCollection = _userCommentCollection(userId);

    await userCommentCollection
        .doc(userComment.id.value)
        .set(userComment.data.toDbData());
  }

  /// Delete the reference to the comment that the user made.
  Future<void> deleteUserComment(
    UserIdFirestore userId,
    CommentIdFirestore commentId,
  ) async {
    final userCommentCollection = _userCommentCollection(userId);

    await userCommentCollection.doc(commentId.value).delete();
  }
}

final userCommentRepositoryServiceProvider =
    Provider<UserCommentRepositoryService>(
  (ref) => UserCommentRepositoryService(
    firestore: ref.watch(firestoreProvider),
  ),
);