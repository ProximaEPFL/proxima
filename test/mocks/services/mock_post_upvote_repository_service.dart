import "package:cloud_firestore/cloud_firestore.dart";
import "package:mockito/mockito.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/models/database/vote/upvote_state.dart";
import "package:proxima/services/database/post_upvote_repository_service.dart";

class MockPostUpvoteRepositoryService extends Mock
    implements PostUpvoteRepositoryService {
  @override
  Future<UpvoteState> getUpvoteState(
    UserIdFirestore? userId,
    PostIdFirestore? postId, {
    Transaction? transaction,
  }) {
    return super.noSuchMethod(
      Invocation.method(#getUpvoteState, [userId, postId, transaction]),
      returnValue: Future.value(UpvoteState.none),
    );
  }

  @override
  Future<void> setUpvoteState(
    UserIdFirestore? userId,
    PostIdFirestore? postId,
    UpvoteState? upvoteState,
  ) {
    return super.noSuchMethod(
      Invocation.method(#setUpvoteState, [userId, postId, upvoteState]),
      returnValue: Future.value(),
    );
  }
}
