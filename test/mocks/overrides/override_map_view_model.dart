import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/map_view_model.dart";

class MockMapViewModel extends AsyncNotifier<MapInfo> implements MapViewModel {
  @override
  Future<MapInfo> build() async {
    throw Exception("Location services are disabled.");
  }

  @override
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}
