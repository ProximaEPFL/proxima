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
  final PostCommentRepositoryService _postRepository;
  final UserCommentRepositoryService _userRepository;

  CommentRepositoryService({
    required FirebaseFirestore firestore,
  })  : _postRepository = PostCommentRepositoryService(firestore: firestore),
        _userRepository = UserCommentRepositoryService(firestore: firestore);

  /// This method returns the comments of the post with id [parentPostId]
  Future<List<CommentFirestore>> getPostComments(
    PostIdFirestore parentPostId,
  ) =>
      _postRepository.getComments(parentPostId);

  /// This method returns the comments of the user with id [userId]
  Future<List<UserCommentFirestore>> getUserComments(
    UserIdFirestore userId,
  ) =>
      _userRepository.getUserComments(userId);

  // Note: The addition/deletion of the comment under the post and the comment under the
  // the user document are not done atomically.
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
    final commentId = await _postRepository.addComment(
      parentPostId,
      commentData,
    );

    final userCommentData = UserCommentData(
      parentPostId: parentPostId,
      content: commentData.content,
    );

    final userComment =
        UserCommentFirestore(id: commentId, data: userCommentData);

    await _userRepository.addUserComment(commentData.ownerId, userComment);

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
    await _postRepository.deleteComment(parentPostId, commentId);

    await _userRepository.deleteUserComment(
      ownerId,
      commentId,
    );
  }
}

final commentRepositoryServiceProvider = Provider<CommentRepositoryService>(
  (ref) => CommentRepositoryService(
    firestore: ref.watch(firestoreProvider),
  ),
);
