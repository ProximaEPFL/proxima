import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/services/database/firestore_service.dart";
import "package:proxima/services/database/upvote_repository_service.dart";

final postUpvoteRepositoryServiceProvider =
    Provider<UpvoteRepositoryService<PostIdFirestore>>((ref) {
  return UpvoteRepositoryService.postUpvoteRepositoryService(
    ref.watch(firestoreProvider),
  );
});
