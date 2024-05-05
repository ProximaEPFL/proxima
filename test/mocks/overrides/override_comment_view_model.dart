import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/ui/comment_post.dart";
import "package:proxima/viewmodels/comment_view_model.dart";

import "../data/post_comment.dart";

/// A mock implementation of the [CommentViewModel] class.
/// By default it exposes an empty list of [CommentPost] and does nothing on refresh.
class MockCommentViewModel
    extends AutoDisposeFamilyAsyncNotifier<List<CommentPost>, PostIdFirestore>
    implements CommentViewModel {
  final Future<List<CommentPost>> Function(PostIdFirestore arg) _build;
  final Future<void> Function() _onRefresh;

  MockCommentViewModel({
    Future<List<CommentPost>> Function(PostIdFirestore arg)? build,
    Future<void> Function()? onRefresh,
  })  : _build =
            build ?? ((PostIdFirestore arg) async => List<CommentPost>.empty()),
        _onRefresh = onRefresh ?? (() async {});

  @override
  Future<List<CommentPost>> build(PostIdFirestore arg) => _build(arg);

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

final mockLoadingCommentViewModelOverride = [
  commentListProvider.overrideWith(
    () => MockCommentViewModel(
      // Future.any([]) will never complete and simulate a loading state
      build: (PostIdFirestore arg) => Future.any([]),
    ),
  ),
];
