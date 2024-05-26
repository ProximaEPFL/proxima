import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/viewmodels/post_comment_count_view_model.dart";

/// A mock implementation of the [PostCommentCountViewModel] class.
/// Its state is always the same and can be set in the constructor.
class MockPostCommentCountViewModel
    extends FamilyAsyncNotifier<int, PostIdFirestore>
    implements PostCommentCountViewModel {
  final int count;

  /// Creates a new [MockPostCommentCountViewModel] with the given [count],
  /// which is the value that will always be returned by this view-model.
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
