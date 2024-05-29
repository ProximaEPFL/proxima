import "dart:async";

import "package:flutter/material.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/map_details.dart";
import "package:proxima/services/sensors/geolocation_service.dart";
import "package:proxima/utils/extensions/geopoint_extensions.dart";
import "package:proxima/viewmodels/posts_feed_view_model.dart";

/// This view model is responsible for managing the actual location
/// of the user on the map and the displayed circles.
class MapViewModel extends AutoDisposeFamilyAsyncNotifier<MapDetails, LatLng?> {
  @override
  Future<MapDetails> build([LatLng? arg]) async {
    if (arg != null) {
      disableFollowUser();
      return MapDetails(
        initialLocation: arg,
      );
    } else {
      enableFollowUser();
      final geoPoint =
          await ref.read(geolocationServiceProvider).getCurrentPosition();
      return MapDetails(
        initialLocation: geoPoint.toLatLng(),
      );
    }
  }

  final Set<Circle> _circles = {};

  // Getter for the circles
  Set<Circle> get circles => _circles;

  void redrawCircle(LatLng target) {
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

  /// This is the initial zoom level of the map
  static const initialZoomLevel = 17.0;

  // This boolean is used to determine if the camera should follow the user
  bool _followUser = true;

  /// Enable the camera to follow the user
  void enableFollowUser() => _followUser = true;

  /// Disable the camera from following the user
  void disableFollowUser() => _followUser = false;

  /// Move the camera to the target location
  /// Only moves the camera if the follow user is enabled
  Future<void> updateCamera(
    LatLng userPosition, {
    bool followEvent = true,
  }) async {
    if (followEvent && !_followUser) return;
    _followUser = followEvent;
    final GoogleMapController controller = await _mapController.future;
    // reset zoom to initial
    // center camera on target
    final CameraPosition cameraPosition =
        CameraPosition(target: userPosition, zoom: initialZoomLevel);
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }
}

final mapViewModelProvider =
    AsyncNotifierProvider.autoDispose.family<MapViewModel, MapDetails, LatLng?>(
  () => MapViewModel(),
);
