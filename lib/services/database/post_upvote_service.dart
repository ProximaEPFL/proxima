import "package:cloud_firestore/cloud_firestore.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_data.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/upvote_state.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/services/database/firestore_service.dart";

class PostUpvoteRepositoryService {
  static const upvotersSubCollectionName = "upvoters";
  static const downvotersSubCollectionName = "downvoters";

  final FirebaseFirestore firestore;

  PostUpvoteRepositoryService({
    required this.firestore,
  });

  DocumentReference<Map<String, dynamic>> _postDocument(
    PostIdFirestore postId,
  ) {
    return firestore.collection(PostFirestore.collectionName).doc(postId.value);
  }

  CollectionReference<Map<String, dynamic>> _upvotersCollection(
    PostIdFirestore postId,
  ) {
    return _postDocument(postId).collection(upvotersSubCollectionName);
  }

  CollectionReference<Map<String, dynamic>> _downvotersCollection(
    PostIdFirestore postId,
  ) {
    return _postDocument(postId).collection(downvotersSubCollectionName);
  }

  Future<UpvoteState> getUpvoteState(
    UserIdFirestore userId,
    PostIdFirestore postId,
  ) async {
    final hasUpVotedReference = _upvotersCollection(postId).doc(userId.value);

    final hasDownVotedReference =
        _downvotersCollection(postId).doc(userId.value);

    return await firestore.runTransaction((transaction) async {
      final hasUpVotedDocument = await transaction.get(hasUpVotedReference);
      if (hasUpVotedDocument.exists) {
        return UpvoteState.upvoted;
      }

      final hasDownVotedCollection =
          await transaction.get(hasDownVotedReference);
      if (hasDownVotedCollection.exists) {
        return UpvoteState.downvoted;
      }

      return UpvoteState.none;
    });
  }

  Future<void> setUpvoteState(
    UserIdFirestore userId,
    PostIdFirestore postId,
    UpvoteState newState,
  ) async {
    return await firestore.runTransaction((transaction) async {
      final currState = await getUpvoteState(userId, postId);
      if (currState == newState) return;

      int increment = 0;

      // Remove the current state, setting it to none.
      if (currState == UpvoteState.upvoted) {
        transaction.delete(_upvotersCollection(postId).doc(userId.value));
        increment -= 1;
      } else if (currState == UpvoteState.downvoted) {
        transaction.delete(_downvotersCollection(postId).doc(userId.value));
        increment += 1;
      }

      // Apply the wanted state.
      if (newState == UpvoteState.upvoted) {
        transaction.set(
          _upvotersCollection(postId).doc(userId.value),
          <String, dynamic>{},
        );
        increment += 1;
      } else if (newState == UpvoteState.downvoted) {
        transaction.set(
          _downvotersCollection(postId).doc(userId.value),
          <String, dynamic>{},
        );
        increment -= 1;
      }

      // Update the vote count
      transaction.update(
        _postDocument(postId),
        {PostData.voteScoreField: FieldValue.increment(increment)},
      );
    });
  }
}

final postUpvoteRepositoryProvider = Provider<PostUpvoteRepositoryService>(
  (ref) => PostUpvoteRepositoryService(
    firestore: ref.watch(firestoreProvider),
  ),
);
