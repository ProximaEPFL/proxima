import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/post_details.dart";
import "package:proxima/viewmodels/posts_feed_view_model.dart";

import "../data/post_overview.dart";

/// A mock implementation of the [PostsFeedViewModel] class.
/// This class is particularly useful for the UI tests where we want to expose
/// particular data to the views.
/// By default it exposes an empty list of [PostDetails] and does nothing on refresh.
class MockPostsFeedViewModel extends AutoDisposeAsyncNotifier<List<PostDetails>>
    implements PostsFeedViewModel {
  final Future<List<PostDetails>> Function() _build;
  final Future<void> Function() _onRefresh;

  MockPostsFeedViewModel({
    Future<List<PostDetails>> Function()? build,
    Future<void> Function()? onRefresh,
  })  : _build = build ?? (() async => List<PostDetails>.empty()),
        _onRefresh = onRefresh ?? (() async {});

  @override
  Future<List<PostDetails>> build() => _build();

  @override
  Future<void> refresh() => _onRefresh();
}

final mockEmptyHomeViewModelOverride = [
  postsFeedViewModelProvider.overrideWith(() => MockPostsFeedViewModel()),
];

final mockNonEmptyHomeViewModelOverride = [
  postsFeedViewModelProvider.overrideWith(
    () => MockPostsFeedViewModel(build: () async => testPosts),
  ),
];

final mockLoadingHomeViewModelOverride = [
  postsFeedViewModelProvider.overrideWith(
    () => MockPostsFeedViewModel(
      // Future.any([]) will never complete and simulate a loading state
      build: () => Future.any([]),
    ),
  ),
];
