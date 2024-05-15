import "package:mockito/mockito.dart";
import "package:proxima/models/database/comment/comment_data.dart";
import "package:proxima/models/database/comment/comment_firestore.dart";
import "package:proxima/models/database/comment/comment_id_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/models/database/user_comment/user_comment_firestore.dart";
import "package:proxima/services/database/comment/comment_repository_service.dart";

class MockCommentRepositoryService extends Mock
    implements CommentRepositoryService {
  @override
  Future<CommentIdFirestore> addComment(
    PostIdFirestore? parentPostId,
    CommentData? commentData,
  ) {
    return super.noSuchMethod(
      Invocation.method(#addComment, [parentPostId, commentData]),
      returnValue: Future.value(const CommentIdFirestore(value: "")),
    );
  }

  @override
  Future<void> deleteComment(
    PostIdFirestore? parentPostId,
    CommentIdFirestore? commentId,
    UserIdFirestore? userId,
  ) {
    return super.noSuchMethod(
      Invocation.method(#deleteComment, [parentPostId, commentId]),
      returnValue: Future.value(),
    );
  }

  @override
  Future<List<CommentFirestore>> getPostComments(
    PostIdFirestore? parentPostId,
  ) {
    return super.noSuchMethod(
      Invocation.method(#getComments, [parentPostId]),
      returnValue: Future.value(List<CommentFirestore>.empty()),
    );
  }

  @override
  Future<List<UserCommentFirestore>> getUserComments(
    UserIdFirestore? userId,
  ) {
    return super.noSuchMethod(
      Invocation.method(#getUserComments, [userId]),
      returnValue: Future.value(List<UserCommentFirestore>.empty()),
    );
  }
}
