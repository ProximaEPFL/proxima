import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/comment/comment_data.dart";
import "package:proxima/models/database/comment/comment_firestore.dart";
import "package:proxima/models/database/comment/comment_id_firestore.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/services/database/firestore_service.dart";
import "package:proxima/services/database/upvote_repository_service.dart";

final commentUpvoteRepositoryService = Provider.family<
    UpvoteRepositoryService<CommentIdFirestore>,
    PostIdFirestore>((ref, postId) {
  final firestore = ref.read(firestoreProvider);
  final parentCollection = firestore
      .collection(PostFirestore.collectionName)
      .doc(postId.value)
      .collection(CommentFirestore.subCollectionName);

  return UpvoteRepositoryService(
    firestore: firestore,
    parentCollection: parentCollection,
    voteScoreField: CommentData.voteScoreField,
  );
});
