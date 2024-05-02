import "package:cloud_firestore/cloud_firestore.dart";
import "package:mockito/mockito.dart";
import "package:proxima/models/database/firestore/id_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/models/database/vote/upvote_state.dart";
import "package:proxima/services/database/upvote_repository_service.dart";

class MockUpvoteRepositoryService<ParentIdFirestore extends IdFirestore>
    extends Mock implements UpvoteRepositoryService<ParentIdFirestore> {
  @override
  Future<UpvoteState> getUpvoteState(
    UserIdFirestore? userId,
    ParentIdFirestore? parentId, {
    Transaction? transaction,
  }) {
    return super.noSuchMethod(
      Invocation.method(
        #getUpvoteState,
        [userId, parentId],
        {#transaction: transaction},
      ),
      returnValue: Future.value(UpvoteState.none),
    );
  }

  @override
  Future<void> setUpvoteState(
    UserIdFirestore? userId,
    ParentIdFirestore? parentId,
    UpvoteState? newState,
  ) {
    return super.noSuchMethod(
      Invocation.method(
        #setUpvoteState,
        [userId, parentId, newState],
      ),
      returnValue: Future.value(),
    );
  }
}
