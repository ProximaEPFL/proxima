import "dart:async";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/services/geolocation_service.dart";

class MapInfo {
  const MapInfo({
    required this.currentLocation,
  });
  final LatLng currentLocation;
}

final asyncMapProvider = AsyncNotifierProvider<MapNotifier, MapInfo>(
  () => MapNotifier(),
);

class MapNotifier extends AsyncNotifier<MapInfo> {
  @override
  Future<MapInfo> build() async {
    GeoPoint position =
        await ref.read(geoLocationServiceProvider).getCurrentPosition();
    return MapInfo(
      currentLocation: LatLng(position.latitude, position.longitude),
    );
  }

  final Completer<GoogleMapController> _mapController = Completer();

  void onMapCreated(GoogleMapController controller) {
    if (!_mapController.isCompleted) _mapController.complete(controller);
  }

  Future<void> getCurrentLocation() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await build());
  }
}
