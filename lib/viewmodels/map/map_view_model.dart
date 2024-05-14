import "dart:async";

import "package:flutter/material.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/map_details.dart";
import "package:proxima/services/sensors/geolocation_service.dart";
import "package:proxima/viewmodels/posts_feed_view_model.dart";
import "package:proxima/views/components/options/map/map_selection_option.dart";

/// This view model is responsible for managing the actual location
/// of the user on the map and the displayed circles.
class MapViewModel extends AutoDisposeAsyncNotifier<MapDetails> {
  @override
  Future<MapDetails> build() async {
    final actualLocation =
        await ref.read(geolocationServiceProvider).getCurrentPosition();
    return MapDetails(
      initialLocation:
          LatLng(actualLocation.latitude, actualLocation.longitude),
      selectOption: MapSelectionOptions.nearby,
    );
  }

  final Set<Circle> _circles = {};

  // Getter for the circles
  Set<Circle> get circles => _circles;

  Future<void> redrawCircle(LatLng target) async {
    _circles.clear();
    _circles.add(
      Circle(
        circleId: const CircleId("1"),
        center: target,
        radius: PostsFeedViewModel.kmPostRadius * 1000,
        fillColor: Colors.black26,
        strokeWidth: 0,
      ),
    );
  }

  final Completer<GoogleMapController> _mapController = Completer();

  // Getter for the map controller
  Completer<GoogleMapController> get mapController => _mapController;

  void onMapCreated(GoogleMapController controller) async {
    if (_mapController.isCompleted) return;
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

final mapViewModelProvider =
    AsyncNotifierProvider.autoDispose<MapViewModel, MapDetails>(
  () => MapViewModel(),
);
