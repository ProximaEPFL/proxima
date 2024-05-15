import "package:mockito/mockito.dart";
import "package:proxima/models/database/comment/comment_data.dart";
import "package:proxima/models/database/comment/comment_firestore.dart";
import "package:proxima/models/database/comment/comment_id_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/services/database/comment/post_comment_repository_service.dart";

class MockCommentRepositoryService extends Mock
    implements PostCommentRepositoryService {
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
  ) {
    return super.noSuchMethod(
      Invocation.method(#deleteComment, [parentPostId, commentId]),
      returnValue: Future.value(),
    );
  }

  @override
  Future<List<CommentFirestore>> getComments(PostIdFirestore? parentPostId) {
    return super.noSuchMethod(
      Invocation.method(#getComments, [parentPostId]),
      returnValue: Future.value(List<CommentFirestore>.empty()),
    );
  }
}
