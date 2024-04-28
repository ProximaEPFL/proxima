import "package:cloud_firestore/cloud_firestore.dart";
import "package:proxima/models/database/comment/comment_data.dart";
import "package:proxima/models/database/comment/comment_firestore.dart";
import "package:proxima/models/database/comment/comment_id_firestore.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";

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
  CollectionReference<Map<String, dynamic>> _commentsCollection(
    PostIdFirestore postId,
  ) {
    return _postDocument(postId).collection(CommentFirestore.subCollectionName);
  }

  /// This method returns the comments of the post with id [postId]
  Future<List<CommentFirestore>> getComments(PostIdFirestore postId) async {
    return [];
  }

  /// This method will add the comment with data [commentData] to the
  /// post with id [parentPostId].
  /// It will also update the number of comments of the post.
  /// This is done atomically, possibly as part of the transaction [transaction].
  ///
  /// The method returns the id of the comment that was added.
  Future<CommentIdFirestore> addComment(
    PostIdFirestore parentPostId,
    CommentData commentData, {
    Transaction? transaction,
  }) async {
    return const CommentIdFirestore(value: "");
  }

  /// This method will delete the comment with id [commentId] from the
  /// post with id [parentPostId].
  /// It will also update the number of comments of the post.
  /// This is done atomically, possibly as part of the transaction [transaction].
  /// If the comment does not exist, the method will do nothing.
  Future<void> deleteComment(
    PostIdFirestore parentPostId,
    CommentIdFirestore commentId, {
    Transaction? transaction,
  }) async {
    return;
  }
}
