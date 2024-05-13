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
  static const initialZoomLevel = 17.5;

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

    positionValue.when(
      data: (data) {
        mapNotifier.redrawCircle(LatLng(data!.latitude, data.longitude));
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

    return Expanded(
      child: GoogleMap(
        key: postMapKey,
        mapType: MapType.normal,
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        zoomGesturesEnabled: true,
        zoomControlsEnabled: true,
        scrollGesturesEnabled: true,
        rotateGesturesEnabled: false,
        tiltGesturesEnabled: false,
        initialCameraPosition: CameraPosition(
          target: mapInfo.initialLocation,
          zoom: initialZoomLevel,
        ),
        circles: mapNotifier.circles,
        markers: mapMarkersNotifier.markers,
        onMapCreated: mapNotifier.onMapCreated,
      ),
    );
  }
}
