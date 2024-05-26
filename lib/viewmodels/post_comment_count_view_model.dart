import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/services/database/post_repository_service.dart";

/// This view model is used to keep in memory the number of comments of a post.
/// It is refreshed every time the post comment list is refreshed, to stay consistent
/// with it. It is also refreshed when a comment is deleted.
/// This cannot be auto-dispose because, otherwise, it might get unmounted in the middle
/// of its refresh method. See https://github.com/rrousselGit/riverpod/discussions/2502.
class PostCommentCountViewModel
    extends FamilyAsyncNotifier<int, PostIdFirestore> {
  @override
  Future<int> build(PostIdFirestore arg) async {
    final postRepo = ref.watch(postRepositoryServiceProvider);
    final post = await postRepo.getPost(arg);
    return post.data.commentCount;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build(arg));
  }
}

final postCommentCountProvider = AsyncNotifierProvider.family<
    PostCommentCountViewModel, int, PostIdFirestore>(
  () => PostCommentCountViewModel(),
);
