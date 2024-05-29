import "package:cloud_firestore/cloud_firestore.dart";
import "package:proxima/models/database/comment/comment_id_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/models/database/user_comment/user_comment_data.dart";
import "package:proxima/models/database/user_comment/user_comment_firestore.dart";

/// This class is responsible for managing the user's comments in the firestore database.
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

  /// Get the references to the user's comments whose id is [userId].
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

  /// Add a reference [userComment] in the user's document to keep
  /// track of the comment that the user with id [userId] made.
  Future<void> addUserComment(
    UserIdFirestore userId,
    UserCommentFirestore userComment,
  ) async {
    final userCommentCollection = _userCommentCollection(userId);

    await userCommentCollection
        .doc(userComment.id.value)
        .set(userComment.data.toDbData());
  }

  /// Delete the reference to the comment with id [commentId] that the user
  /// with id [userId] made.
  /// The deletion is not performed directly but added to the write batch [batch]
  void deleteUserComment(
    UserIdFirestore userId,
    CommentIdFirestore commentId,
    WriteBatch batch,
  ) {
    final commentToDelete = _userCommentCollection(userId).doc(commentId.value);

    batch.delete(commentToDelete);
  }

  /// Check if the user with id [userId] has commented at least once
  ///  under the post with id [parentPostId].
  Future<bool> hasUserCommentedUnderPost(
    UserIdFirestore userId,
    PostIdFirestore parentPostId,
  ) async {
    final userCommentCollection = _userCommentCollection(userId);

    // Here, we limit the query to 1 because we only need to know if the user
    // has commented at least once under the post. This limits the number of
    // documents that need to be retrieved and improves the performance.
    final userCommentQuery = await userCommentCollection
        .where(UserCommentData.parentPostIdField, isEqualTo: parentPostId.value)
        .limit(1)
        .get();

    return userCommentQuery.docs.isNotEmpty;
  }
}
