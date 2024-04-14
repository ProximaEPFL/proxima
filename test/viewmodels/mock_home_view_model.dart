import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/post_overview.dart";
import "package:proxima/viewmodels/home_view_model.dart";

/// A mock implementation of the [HomeViewModel] class.
/// This class is particularly useful for the UI tests where we want to expose
/// particular data to the views.
/// By default it exposes an empty list of [PostOverview] and does nothing on refresh.
class MockHomeViewModel extends AutoDisposeStreamNotifier<List<PostOverview>>
    implements HomeViewModel {
  final Stream<List<PostOverview>> Function() _build;
  final void Function() _onRefresh;

  MockHomeViewModel({
    Stream<List<PostOverview>> Function()? build,
    void Function()? onRefresh,
  })  : _build = build ?? (() => Stream.value(List<PostOverview>.empty())),
        _onRefresh = onRefresh ?? (() {});

  @override
  Stream<List<PostOverview>> build() => _build();

  @override
  void refresh() => _onRefresh();
}

final mockEmptyHomeViewModelOverride = [
  postOverviewProvider.overrideWith(() => MockHomeViewModel()),
];
