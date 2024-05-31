import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/ui/comment_count_details.dart";
import "package:proxima/services/database/comment/comment_repository_service.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";

/// This view model is used to keep in memory the state of the comment count of a post.
/// It is refreshed every time the post comment list is refreshed, to stay consistent
/// with it. It is also refreshed when a comment is deleted.
/// This cannot be auto-dispose because, otherwise, it might get unmounted in the middle
/// of its refresh method. See https://github.com/rrousselGit/riverpod/discussions/2502.
class PostCommentCountViewModel
    extends FamilyAsyncNotifier<CommentCountDetails, PostIdFirestore> {
  @override
  Future<CommentCountDetails> build(PostIdFirestore arg) async {
    final postRepo = ref.watch(postRepositoryServiceProvider);
    final commentRepo = ref.watch(commentRepositoryServiceProvider);
    final userId = ref.read(loggedInUserIdProvider);
    if (userId == null) {
      throw Exception("User not logged in");
    }

    final postFuture = postRepo.getPost(arg);
    final hasUserCommentedFuture =
        commentRepo.hasUserCommentedUnderPost(userId, arg);

    // Wait for both futures in parallel
    final results = await (
      postFuture,
      hasUserCommentedFuture,
    ).wait;

    final post = results.$1;
    final hasUserCommented = results.$2;

    return CommentCountDetails(
      count: post.data.commentCount,
      isIconBlue: hasUserCommented,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build(arg));
  }
}

final postCommentCountProvider = AsyncNotifierProvider.family<
    PostCommentCountViewModel, CommentCountDetails, PostIdFirestore>(
  () => PostCommentCountViewModel(),
);
