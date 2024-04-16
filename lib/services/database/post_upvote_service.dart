import "package:cloud_firestore/cloud_firestore.dart";
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
}
