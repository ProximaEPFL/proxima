import "package:cloud_firestore/cloud_firestore.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/comment/comment_data.dart";
import "package:proxima/models/database/comment/comment_firestore.dart";
import "package:proxima/models/database/comment/comment_id_firestore.dart";
import "package:proxima/models/database/post/post_data.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/services/database/firestore_service.dart";

/// This class is a service that allows to interact with the comments
/// of the posts in the firestore database.
class CommentRepositoryService {
  final FirebaseFirestore _firestore;

  CommentRepositoryService({required FirebaseFirestore firestore})
      : _firestore = firestore;

  /// Returns the document reference of the post with id [postId]
  DocumentReference<Map<String, dynamic>> _postDocument(
    PostIdFirestore postId,
  ) {
    return _firestore
        .collection(PostFirestore.collectionName)
        .doc(postId.value);
  }

  /// Returns the collection reference of the subcollection of comments of
  /// the post with id [postId]
  CollectionReference<Map<String, dynamic>> _commentsSubCollection(
    PostIdFirestore postId,
  ) {
    return _postDocument(postId).collection(CommentFirestore.subCollectionName);
  }

  /// This method returns the comments of the post with id [postId]
  Future<List<CommentFirestore>> getComments(PostIdFirestore postId) async {
    final commentsQuery = await _commentsSubCollection(postId).get();

    final comments = commentsQuery.docs
        .map((docSnap) => CommentFirestore.fromDb(docSnap))
        .toList();

    return comments;
  }

  /// This method will add the comment with data [commentData] to the
  /// post with id [parentPostId].
  /// It will also update the number of comments of the post.
  /// This is done atomically.
  ///
  /// The method returns the id of the comment that was added.
  Future<CommentIdFirestore> addComment(
    PostIdFirestore parentPostId,
    CommentData commentData,
  ) async {
    // Generate a new reference for the comment
    // Although generated locally, the new id can be considered unique
    // https://stackoverflow.com/questions/54268257/what-are-the-chances-for-firestore-to-generate-two-identical-random-keys
    final newCommentRef = _commentsSubCollection(parentPostId).doc();

    // Create a batch write to perform the operations atomically
    final batch = _firestore.batch();

    batch.set(newCommentRef, commentData.toDbData());

    final postDocRef = _postDocument(parentPostId);
    batch.update(
      postDocRef,
      {PostData.commentCountField: FieldValue.increment(1)},
    );

    await batch.commit();

    return CommentIdFirestore(value: newCommentRef.id);
  }

  /// This method will delete the comment with id [commentId] from the
  /// post with id [parentPostId].
  /// It will also update the number of comments of the post.
  /// This is done atomically.
  /// If the comment does not exist, the method will do nothing.
  Future<void> deleteComment(
    PostIdFirestore parentPostId,
    CommentIdFirestore commentId,
  ) async {
    await _firestore.runTransaction((transaction) async {
      await _deleteComment(parentPostId, commentId, transaction);
    });
  }

  // Concrete implementation of the deletion of a comment
  Future<void> _deleteComment(
    PostIdFirestore parentPostId,
    CommentIdFirestore commentId,
    Transaction transaction,
  ) async {
    final commentRef =
        _commentsSubCollection(parentPostId).doc(commentId.value);

    final commentDoc = await transaction.get(commentRef);

    if (!commentDoc.exists) {
      return;
    }

    transaction.delete(commentRef);

    final postDocRef = _postDocument(parentPostId);
    transaction.update(
      postDocRef,
      {PostData.commentCountField: FieldValue.increment(-1)},
    );
  }
}

final commentRepositoryProvider = Provider<CommentRepositoryService>(
  (ref) => CommentRepositoryService(
    firestore: ref.watch(firestoreProvider),
  ),
);
