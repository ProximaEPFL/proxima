import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/comment/comment_id_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/services/database/firestore_service.dart";
import "package:proxima/services/database/upvote_repository_service.dart";

final commentUpvoteRepositoryServiceProvider = Provider.family<
    UpvoteRepositoryService<CommentIdFirestore>,
    PostIdFirestore>((ref, postId) {
  return UpvoteRepositoryService.commentUpvoteRepositoryService(
    ref.watch(firestoreProvider),
    postId,
  );
});
