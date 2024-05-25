import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/services/database/post_repository_service.dart";

/// This view model is used to keep in memory the number of comments of a post.
/// It is refreshed every time the post comment list is refreshed, to stay consistent
/// with it. It is also refreshed when a comment is deleted.
/// The fact that it is auto-dispose allows to keep the memory usage low, keeping only
/// the count of the comments of the posts that are currently displayed on the screen.
/// This may moreover help mitigate some reloading bugs, since it suffices to scroll
/// the post out of the screen to dispose the view model and thus the count of the comments.
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
  void setCount(int count) {
    state = AsyncValue.data(count);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => build(arg));
  }
}

final postCommentCountProvider = AsyncNotifierProvider.autoDispose
    .family<PostCommentCountViewModel, int, PostIdFirestore>(
  () => PostCommentCountViewModel(),
);
