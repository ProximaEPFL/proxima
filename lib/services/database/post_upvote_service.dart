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

  final FirebaseFirestore firestore;

  PostUpvoteRepositoryService({
    required this.firestore,
  });

  /// Returns the document reference of the post with id [postId]
  DocumentReference<Map<String, dynamic>> _postDocument(
    PostIdFirestore postId,
  ) {
    return firestore.collection(PostFirestore.collectionName).doc(postId.value);
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

  /// Sets the upvote state of the user with id [userId] on the post with id [postId]
  /// to [newState]. This is done atomically.
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
