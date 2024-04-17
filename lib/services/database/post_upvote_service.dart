import "package:cloud_firestore/cloud_firestore.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_data.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/upvote_state.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/services/database/firestore_service.dart";

/// This repository service is responsible for handling the upvotes of posts
class PostUpvoteRepositoryService {
  /// The name of the subcollection that contains the list of users who upvoted
  static const upvotersSubCollectionName = "upvoters";

  /// The name of the subcollection that contains the list of users who downvoted
  static const downvotersSubCollectionName = "downvoters";

  final FirebaseFirestore _firestore;

  PostUpvoteRepositoryService({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  /// Returns the document reference of the post with id [postId]
  DocumentReference<Map<String, dynamic>> _postDocument(
    PostIdFirestore postId,
  ) {
    return _firestore
        .collection(PostFirestore.collectionName)
        .doc(postId.value);
  }

  /// Returns the collection reference of the subcollection that contains the
  /// list of users who upvoted the post with id [postId]
  CollectionReference<Map<String, dynamic>> _upvotersCollection(
    PostIdFirestore postId,
  ) {
    return _postDocument(postId).collection(upvotersSubCollectionName);
  }

  /// Returns the collection reference of the subcollection that contains the
  /// list of users who downvoted the post with id [postId]
  CollectionReference<Map<String, dynamic>> _downvotersCollection(
    PostIdFirestore postId,
  ) {
    return _postDocument(postId).collection(downvotersSubCollectionName);
  }

  /// Returns the upvote state of the user with id [userId] on the post with id [postId]
  /// This is done atomically.
  Future<UpvoteState> getUpvoteState(
    UserIdFirestore userId,
    PostIdFirestore postId,
  ) async {
    final hasUpVotedReference = _upvotersCollection(postId).doc(userId.value);

    final hasDownVotedReference =
        _downvotersCollection(postId).doc(userId.value);

    return await _firestore.runTransaction((transaction) async {
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

  /// Sets the upvote state of the user with id [userId] on the post with id [postId]
  /// to [newState]. This is done atomically.
  Future<void> setUpvoteState(
    UserIdFirestore userId,
    PostIdFirestore postId,
    UpvoteState newState,
  ) async {
    return await _firestore.runTransaction((transaction) async {
      final currState = await getUpvoteState(userId, postId);
      if (currState == newState) return;

      int increment = 0;

      // Remove the current state, setting it to none.
      if (currState != UpvoteState.none) {
        if (currState == UpvoteState.upvoted) {
          increment -= 1;
        } else /* currState == UpvoteState.downvoted */ {
          increment += 1;
        }

        final voterCollection = currState == UpvoteState.upvoted
            ? _upvotersCollection
            : _downvotersCollection;
        transaction.delete(voterCollection(postId).doc(userId.value));
      }

      // Apply the wanted state.
      if (newState != UpvoteState.none) {
        if (newState == UpvoteState.upvoted) {
          increment += 1;
        } else /* newState == UpvoteState.downvoted */ {
          increment -= 1;
        }

        final voterCollection = newState == UpvoteState.upvoted
            ? _upvotersCollection
            : _downvotersCollection;
        transaction.set(
          voterCollection(postId).doc(userId.value),
          <String, dynamic>{},
        );
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
