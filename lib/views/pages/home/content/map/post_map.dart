import "package:flutter/material.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/map_details.dart";
import "package:proxima/services/sensors/geolocation_service.dart";
import "package:proxima/viewmodels/map/map_markers_view_model.dart";
import "package:proxima/viewmodels/map/map_pin_view_model.dart";
import "package:proxima/viewmodels/map/map_view_model.dart";
import "package:proxima/views/components/async/error_alert.dart";

/// This widget displays the Google Map
class PostMap extends ConsumerWidget {
  final MapDetails mapInfo;

  static const postMapKey = Key("postMap");

  const PostMap({
    super.key,
    required this.mapInfo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This provider is used to get information about the map.
    final mapNotifier = ref.watch(mapViewModelProvider.notifier);

    // This provider is used to keep track of the markers on the map.
    final mapMarkersNotifier = ref.watch(mapMarkersViewModelProvider.notifier);

    // This provider is used to get the list of map pins.
    final mapPinsAsync = ref.watch(mapPinViewModelProvider);

    // This provider is used to get the live location of the user.
    final positionValue = ref.watch(livePositionStreamProvider);

    // This will redraw the circle and update camera when the user's position changes.
    positionValue.when(
      data: (data) {
        LatLng userPosition = LatLng(data!.latitude, data.longitude);
        mapNotifier.redrawCircle(userPosition);
        mapNotifier.moveCamera(userPosition);
      },
      error: (error, _) {
        //Pop up an error dialog if an error occurs
        final dialog = ErrorAlert(error: error);

        WidgetsBinding.instance.addPostFrameCallback((timestamp) {
          showDialog(context: context, builder: dialog.build);
        });
      },
      loading: () => (),
    );

    mapPinsAsync.when(
      data: mapMarkersNotifier.updateMarkers,
      error: (error, _) {
        //Pop up an error dialog if an error occurs
        final dialog = ErrorAlert(error: error);

        WidgetsBinding.instance.addPostFrameCallback((timestamp) {
          showDialog(context: context, builder: dialog.build);
        });
      },
      loading: () => (),
    );

    final fab = FloatingActionButton(
      onPressed: () {
        // Center the camera on the user's position and follow
        positionValue.whenData((geoPoint) {
          LatLng userPosition = LatLng(geoPoint!.latitude, geoPoint.longitude);
          mapNotifier.enableFollowUser();
          mapNotifier.moveCamera(userPosition);
        });
      },
      child: const Icon(Icons.my_location),
    );

    final googleMap = GoogleMap(
      key: postMapKey,
      mapType: MapType.normal,
      myLocationButtonEnabled: false,
      myLocationEnabled: true,
      zoomGesturesEnabled: true,
      zoomControlsEnabled: false,
      scrollGesturesEnabled: true,
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
      initialCameraPosition: CameraPosition(
        target: mapInfo.initialLocation,
        zoom: mapNotifier.initialZoom,
      ),
      circles: mapNotifier.circles,
      markers: mapMarkersNotifier.markers,
      onMapCreated: mapNotifier.onMapCreated,
    );

    return Expanded(
      child: Scaffold(
        body: googleMap,
        floatingActionButton: fab,
      ),
    );
  }
}
