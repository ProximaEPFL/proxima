import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/ui/comment_details.dart";
import "package:proxima/viewmodels/comment_view_model.dart";

import "../data/post_comment.dart";

/// A mock implementation of the [CommentViewModel] class.
/// By default it exposes an empty list of [CommentDetails] and does nothing on refresh.
class MockCommentViewModel
    extends AutoDisposeFamilyAsyncNotifier<List<CommentDetails>, PostIdFirestore>
    implements CommentViewModel {
  final Future<List<CommentDetails>> Function(PostIdFirestore arg) _build;
  final Future<void> Function() _onRefresh;

  MockCommentViewModel({
    Future<List<CommentDetails>> Function(PostIdFirestore arg)? build,
    Future<void> Function()? onRefresh,
  })  : _build =
            build ?? ((PostIdFirestore arg) async => List<CommentDetails>.empty()),
        _onRefresh = onRefresh ?? (() async {});

  @override
  Future<List<CommentDetails>> build(PostIdFirestore arg) => _build(arg);

  @override
  Future<void> refresh() => _onRefresh();
}

final mockEmptyCommentViewModelOverride = [
  commentListProvider.overrideWith(
    () => MockCommentViewModel(),
  ),
];

final mockNonEmptyCommentViewModelOverride = [
  commentListProvider.overrideWith(
    () => MockCommentViewModel(
      build: (PostIdFirestore arg) async => testComments,
    ),
  ),
];
