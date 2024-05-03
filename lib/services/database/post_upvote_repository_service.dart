import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_data.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/services/database/firestore_service.dart";
import "package:proxima/services/database/upvote_repository_service.dart";

final postUpvoteRepositoryProvider =
    Provider<UpvoteRepositoryService<PostIdFirestore>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return UpvoteRepositoryService(
    firestore: firestore,
    parentCollection: firestore.collection(PostFirestore.collectionName),
    voteScoreField: PostData.voteScoreField,
  );
});
