import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/map_view_model.dart";

class MockMapViewModel extends AsyncNotifier<MapInfo> implements MapViewModel {
  final Future<MapInfo> Function() _build;
  final Future<void> Function() _onRefresh;

  MockMapViewModel({
    Future<MapInfo> Function()? build,
    Future<void> Function()? onRefresh,
  })  : _build = build ??
            (() async => throw Exception("Location services are disabled.")),
        _onRefresh = onRefresh ?? (() async {});

  @override
  Future<MapInfo> build() => _build();

  @override
  Future<void> refresh() => _onRefresh();
}
