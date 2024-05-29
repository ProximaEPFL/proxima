import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/ui/comment_count_details.dart";
import "package:proxima/viewmodels/post_comment_count_view_model.dart";

/// A mock implementation of the [PostCommentCountViewModel] class.
/// Its state is always the same and can be set in the constructor.
class MockPostCommentCountViewModel
    extends FamilyAsyncNotifier<CommentCountDetails, PostIdFirestore>
    implements PostCommentCountViewModel {
  final CommentCountDetails countDetails;

  /// Creates a new [MockPostCommentCountViewModel] with the given [countDetails],
  /// which is the value that will always be returned by this view-model.
  MockPostCommentCountViewModel({
    this.countDetails = CommentCountDetails.empty,
  });

  @override
  Future<CommentCountDetails> build(PostIdFirestore arg) async {
    return countDetails;
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
