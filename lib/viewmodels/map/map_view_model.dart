import "dart:async";

import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/services/geolocation_service.dart";
import "package:proxima/viewmodels/map/map_state.dart";

final mapNotifierProvider = StateNotifierProvider<MapController, MapState>(
  (ref) => MapController(ref),
);

class MapController extends StateNotifier<MapState> {
  MapController(this._ref) : super(const MapState());

  final StateNotifierProviderRef _ref;

  final Completer<GoogleMapController> _mapController = Completer();

  void onMapCreated(GoogleMapController controller) {
    if (!_mapController.isCompleted) _mapController.complete(controller);
  }

  Future<void> getCurrentLocation() async {
    state = state.copyWith(isBusy: true);
    try {
      final data =
          await _ref.read(geoLocationServiceProvider).getCurrentPosition();
      state = state.copyWith(
        isBusy: false,
        currentLocation: LatLng(data.latitude, data.longitude),
      );
    } on Exception catch (e, _) {
      state = state.copyWith(isBusy: false, errorMessage: e.toString());
    }
  }
}
