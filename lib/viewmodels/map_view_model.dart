import "dart:async";
import "package:flutter/material.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/map_info.dart";
import "package:proxima/viewmodels/home_view_model.dart";
import "package:proxima/views/option_widgets/map/map_selection_option.dart";

// TODO: For now, this is code with mock data.
// This will just be replaced when we implement a real view model anyway.
class MapViewModel extends AsyncNotifier<MapInfo> {
  @override
  Future<MapInfo> build() async {
    return const MapInfo(
      currentLocation: LatLng(46.519653, 6.632273),
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

  final Completer<GoogleMapController> _mapController = Completer();

  void onMapCreated(GoogleMapController controller) {
    if (_mapController.isCompleted) return;
    _mapController.complete(controller);
  }

  Future<void> animateCamera(LatLng target) async {
    final controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: target,
          zoom: 17.5,
        ),
      ),
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
