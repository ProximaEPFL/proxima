import "package:collection/collection.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/ui/post_overview.dart";
import "package:proxima/viewmodels/home_view_model.dart";

import "../data/mock_post_overview.dart";

/// A mock implementation of the [HomeViewModel] class.
/// This class is particularly useful for the UI tests where we want to expose
/// particular data to the views.
/// By default it exposes an empty list of [PostOverview] and does nothing on refresh.
class MockHomeViewModel extends AsyncNotifier<
        List<({PostIdFirestore postId, PostOverview postOverview})>>
    implements HomeViewModel {
  final Future<List<({PostIdFirestore postId, PostOverview postOverview})>>
      Function() _build;
  final Future<void> Function() _onRefresh;

  MockHomeViewModel({
    Future<List<({PostIdFirestore postId, PostOverview postOverview})>>
            Function()?
        build,
    Future<void> Function()? onRefresh,
  })  : _build = build ??
            (() async => List<
                ({PostIdFirestore postId, PostOverview postOverview})>.empty()),
        _onRefresh = onRefresh ?? (() async {});

  @override
  Future<List<({PostIdFirestore postId, PostOverview postOverview})>> build() =>
      _build();

  @override
  Future<void> refresh() => _onRefresh();
}

final mockEmptyHomeViewModelOverride = [
  postOverviewProvider.overrideWith(() => MockHomeViewModel()),
];

final mockNonEmptyHomeViewModelOverride = [
  postOverviewProvider.overrideWith(
    () => MockHomeViewModel(
      build: () async => testPosts
          .mapIndexed(
            (index, element) => (
              postId: PostIdFirestore(value: "post_$index"),
              postOverview: element
            ),
          )
          .toList(),
    ),
  ),
];

final mockLoadingHomeViewModelOverride = [
  postOverviewProvider.overrideWith(
    () => MockHomeViewModel(
      build: () {
        // Future.any([]) will never complete and simulate a loading state
        return Future.any([]);
      },
    ),
  ),
];
