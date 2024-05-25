import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/services/database/post_repository_service.dart";

class PostCommentCountViewModel
    extends AutoDisposeFamilyAsyncNotifier<int, PostIdFirestore> {
  @override
  Future<int> build(PostIdFirestore arg) async {
    final postRepo = ref.watch(postRepositoryServiceProvider);
    final post = await postRepo.getPost(arg);
    return post.data.commentCount;
  }

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
