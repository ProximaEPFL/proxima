import "dart:async";
import "package:flutter/material.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/map_info.dart";
import "package:proxima/services/geolocation_service.dart";
import "package:proxima/viewmodels/home_view_model.dart";
import "package:proxima/views/option_widgets/map/map_selection_option.dart";

// TODO: For now, this is code with mock data.
// This will just be replaced when we implement a real view model anyway.
class MapViewModel extends AutoDisposeAsyncNotifier<MapInfo> {
  @override
  Future<MapInfo> build() async {
    final actualLocation =
        await ref.read(geoLocationServiceProvider).getCurrentPosition();
    return MapInfo(
      currentLocation:
          LatLng(actualLocation.latitude, actualLocation.longitude),
      selectOption: MapSelectionOptions.nearby,
    );
  }

  //set of circles drawn on the map
  final Set<Circle> _circles = {};

  //getter for the circles
  Set<Circle> get circles => _circles;

  Future<void> redrawCircle(LatLng target) async {
    _circles.clear();
    _circles.add(
      Circle(
        circleId: const CircleId("1"),
        center: target,
        radius: HomeViewModel.kmPostRadius * 1000,
        fillColor: Colors.black26,
        strokeWidth: 0,
      ),
    );
  }

  Completer<GoogleMapController> _mapController = Completer();

  // Getter for the map controller
  Completer<GoogleMapController> get mapController => _mapController;

  void onMapCreated(GoogleMapController controller) async {
    _mapController = Completer();
    _mapController.complete(controller);
  }

  /// Refresh the mapInfo.
  /// This will put the state of the viewmodel to loading
  /// and update the state accordingly
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

final mapProvider = AsyncNotifierProvider.autoDispose<MapViewModel, MapInfo>(
  () => MapViewModel(),
);
