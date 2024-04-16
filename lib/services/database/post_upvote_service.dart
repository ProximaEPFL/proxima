import "package:cloud_firestore/cloud_firestore.dart";
import "package:proxima/models/database/post/post_data.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/upvote_state.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";

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

  Future<void> _runUpdateTransaction(
    UserIdFirestore userId,
    PostIdFirestore postId, {
    required bool add,
    required bool upvote,
  }) async {
    final votersCollection =
        upvote ? _upvotersCollection(postId) : _downvotersCollection(postId);

    // Note (add == upvote) is equivalent to (add XNOR upvote)
    // If we want to add an upvote or remove a downvote, we add 1.
    // IF we want to add a downvote or remove an upvote, we subtract 1.
    final increment = (add == upvote) ? 1 : -1;

    await firestore.runTransaction(
      (transaction) async {
        final postdocument = await transaction.get(_postDocument(postId));
        final post = PostFirestore.fromDb(postdocument);
        final voteScore = post.data.voteScore;

        if (add) {
          transaction.set(
            votersCollection.doc(userId.value),
            <String, dynamic>{},
          );
        } else {
          transaction.delete(votersCollection.doc(userId.value));
        }
        transaction.update(
          _postDocument(postId),
          {
            PostData.voteScoreField: voteScore + increment,
          },
        );
      },
    );
  }

  Future<void> setUpvoteState(
    UserIdFirestore userId,
    PostIdFirestore postId,
    UpvoteState newState,
  ) async {
    // TODO: Everything should be done in a single transaction

    final currState = await getUpvoteState(userId, postId);
    if (currState == newState) return;

    // Remove the current state, setting it to none.
    if (currState != UpvoteState.none) {
      await _runUpdateTransaction(
        userId,
        postId,
        add: false,
        upvote: currState == UpvoteState.upvoted,
      );
    }

    // Apply the wanted state.
    if (newState != UpvoteState.none) {
      await _runUpdateTransaction(
        userId,
        postId,
        add: true,
        upvote: newState == UpvoteState.upvoted,
      );
    }
  }
}
