import "dart:async";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/services/geolocation_service.dart";

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
    final location =
        await ref.read(geoLocationServiceProvider).getCurrentPosition();
    return MapInfo(
        currentLocation: LatLng(location.latitude, location.longitude));
  }

  /// Refresh the widget
  /// This will put the state of the viewmodel to loading, fetch the location
  /// and update the state accordingly
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

final mapProvider = AsyncNotifierProvider<MapViewModel, MapInfo>(
  () => MapViewModel(),
);
