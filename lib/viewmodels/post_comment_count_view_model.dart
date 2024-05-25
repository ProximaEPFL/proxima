import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/services/database/post_repository_service.dart";

/// This view model is used to keep in memory the number of comments of a post.
/// It is refreshed every time the post comment list is refreshed, to stay consistent
/// with it. Since it is also auto-dispose, as soon as we refresh the posts list,
/// it will be disposed and recreated with the correct fetched data.
class PostCommentCountViewModel
    extends AutoDisposeFamilyAsyncNotifier<int, PostIdFirestore> {
  @override
  Future<int> build(PostIdFirestore arg) async {
    final postRepo = ref.watch(postRepositoryServiceProvider);
    final post = await postRepo.getPost(arg);
    return post.data.commentCount;
  }

  /// Set the count of comments of the post to [count]. This updates
  /// the state without needing to fetch the data from the database.
  Future<void> setCount(int count) async {
    // We wait for the previous future to avoid race conditions with
    // the build function.
    await future;
    state = AsyncValue.data(count);
  }
}

final postCommentCountProvider = AsyncNotifierProvider.autoDispose
    .family<PostCommentCountViewModel, int, PostIdFirestore>(
  () => PostCommentCountViewModel(),
);
