import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/viewmodels/post_comment_count_view_model.dart";

class MockPostCommentCountViewModel
    extends AutoDisposeFamilyAsyncNotifier<int, PostIdFirestore>
    implements PostCommentCountViewModel {
  final int count;

  MockPostCommentCountViewModel({this.count = 0});

  @override
  Future<int> build(PostIdFirestore arg) async {
    return count;
  }

  @override
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build(arg));
  }
}

final zeroPostCommentCountOverride = [
  postCommentCountProvider.overrideWith(() => MockPostCommentCountViewModel()),
];
