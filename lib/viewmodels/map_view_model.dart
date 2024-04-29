import "dart:async";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

class MapInfo {
  MapInfo({
    required this.currentLocation,
  });
  final LatLng currentLocation;
}

// TODO: For now, this is code with mock data.
// This will just be replaced when we implement a real view model anyway.
class MapViewModel extends AsyncNotifier<MapInfo> {
  @override
  Future<MapInfo> build() async {
    return MapInfo(
      currentLocation: const LatLng(46.519653, 6.632273),
    );
  }

  /// Refresh the mapInfo.
  /// This will put the state of the viewmodel to loading
  /// and update the state accordingly
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

final mapProvider = AsyncNotifierProvider<MapViewModel, MapInfo>(
  () => MapViewModel(),
);
