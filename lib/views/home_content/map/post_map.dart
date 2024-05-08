import "package:flutter/material.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/map_info.dart";
import "package:proxima/services/geolocation_service.dart";
import "package:proxima/viewmodels/map_pin_view_model.dart";
import "package:proxima/viewmodels/map_view_model.dart";

/// This widget displays the Google Map
class PostMap extends ConsumerWidget {
  final MapInfo mapInfo;
  static const initialZoomLevel = 17.5;

  static const postMapKey = Key("postMap");

  const PostMap({
    super.key,
    required this.mapInfo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This provider is used to get information about the map.
    final mapNotifier = ref.watch(mapProvider.notifier);

    // This provider is used to get the list of map pins.
    final mapPinsAsync = ref.watch(mapPinProvider);

    // This provider is used to get the live location of the user.
    final positionValue = ref.watch(liveLocationServiceProvider);

    positionValue.when(
      data: (data) {
        mapNotifier.redrawCircle(LatLng(data!.latitude, data.longitude));
      },
      error: (error, _) {
        throw Exception("Live location error: $error");
      },
      loading: () => (),
    );

    //list of Marker displayed on the map
    Set<Marker> markers = {};

    mapPinsAsync.when(
      data: (data) {
        markers = data
            .map(
              (pin) => Marker(
                markerId: pin.id,
                position: pin.position,
                onTap: pin.callbackFunction,
              ),
            )
            .toSet();
      },
      error: (error, _) {
        throw Exception("Map pins error: $error");
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
        markers: markers,
        onMapCreated: mapNotifier.onMapCreated,
      ),
    );
  }
}
