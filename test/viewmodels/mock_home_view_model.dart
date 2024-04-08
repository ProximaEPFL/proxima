import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/post_overview.dart";
import "package:proxima/viewmodels/home_view_model.dart";

class MockHomeViewModel extends AsyncNotifier<List<PostOverview>>
    implements HomeViewModel {
  // build function
  final Future<List<PostOverview>> Function() _build;

  MockHomeViewModel({required build}) : _build = build;

  @override
  Future<List<PostOverview>> build() {
    return _build();
  }
}
