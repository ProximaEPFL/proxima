import "package:cloud_firestore/cloud_firestore.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/comment/comment_data.dart";
import "package:proxima/models/database/comment/comment_firestore.dart";
import "package:proxima/models/database/comment/comment_id_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/models/database/user_comment/user_comment_data.dart";
import "package:proxima/models/database/user_comment/user_comment_firestore.dart";
import "package:proxima/services/database/comment/post_comment_repository_service.dart";
import "package:proxima/services/database/comment/user_comment_repository_service.dart";
import "package:proxima/services/database/firestore_service.dart";

/// This service allows to interact with the comments of the application.
/// It will allow to add, delete and retrieve comments from the firestore database.
/// And it will handle the references between the comments and the users.
class CommentRepositoryService {
  final FirebaseFirestore _firestore;
  final PostCommentRepositoryService _postCommentRepo;
  final UserCommentRepositoryService _userCommentRepo;

  CommentRepositoryService({
    required FirebaseFirestore firestore,
  })  : _firestore = firestore,
        _postCommentRepo = PostCommentRepositoryService(firestore: firestore),
        _userCommentRepo = UserCommentRepositoryService(firestore: firestore);

  /// This method returns the comments of the post with id [parentPostId]
  Future<List<CommentFirestore>> getPostComments(
    PostIdFirestore parentPostId,
  ) =>
      _postCommentRepo.getComments(parentPostId);

  /// This method returns the comments of the user with id [userId]
  Future<List<UserCommentFirestore>> getUserComments(
    UserIdFirestore userId,
  ) =>
      _userCommentRepo.getUserComments(userId);

  // Note: The addition/deletion/allDeletion of the comment under the post and the comment under the
  // the user document are not done fully atomically.
  // This is because integrating atomicity would require a complex refactor
  // that does not add much value to the application.
  // In the worst case, the link between the comment and the user is lost,
  // but the database is still consistent and won't crash the application.

  /// This method will add the comment with data [commentData] to the
  /// post with id [parentPostId].
  /// It will also add a reference to the comment in the user document of the owner.
  Future<CommentIdFirestore> addComment(
    PostIdFirestore parentPostId,
    CommentData commentData,
  ) async {
    final commentId = await _postCommentRepo.addComment(
      parentPostId,
      commentData,
    );

    final userCommentData = UserCommentData(
      parentPostId: parentPostId,
      content: commentData.content,
    );

    final userComment =
        UserCommentFirestore(id: commentId, data: userCommentData);

    await _userCommentRepo.addUserComment(commentData.ownerId, userComment);

    return commentId;
  }

  /// This method will delete the comment with id [commentId] from the
  /// post with id [parentPostId].
  /// It will also delete the reference to the comment from the owner whose
  /// id is [ownerId].
  Future<void> deleteComment(
    PostIdFirestore parentPostId,
    CommentIdFirestore commentId,
    UserIdFirestore ownerId,
  ) async {
    final deleteCommentFuture =
        _postCommentRepo.deleteComment(parentPostId, commentId);

    final batch = _firestore.batch();
    _userCommentRepo.deleteUserComment(
      ownerId,
      commentId,
      batch,
    );
    final deleteUserCommentFuture = batch.commit();

    await Future.wait([deleteCommentFuture, deleteUserCommentFuture]);
  }

  /// This method will delete all the comments under the post with id [parentPostId].
  /// It will also delete all the references to the comments from the owners.
  /// The post comments are deleted in a batch [batch].
  Future<void> deleteAllComments(
    PostIdFirestore parentPostId,
    WriteBatch batch,
  ) async {
    final comments = await getPostComments(parentPostId);

    // The user comments are deleted in parallel
    for (final comment in comments) {
      _userCommentRepo.deleteUserComment(
        comment.data.ownerId,
        comment.id,
        batch,
      );
    }

    // The post comments are deleted in a batch
    await _postCommentRepo.deleteAllComments(parentPostId, batch);
  }
}

final commentRepositoryServiceProvider = Provider<CommentRepositoryService>(
  (ref) => CommentRepositoryService(
    firestore: ref.watch(firestoreProvider),
  ),
);
