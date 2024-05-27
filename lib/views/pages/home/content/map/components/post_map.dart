import "package:flutter/material.dart";
import "package:geolocator/geolocator.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/map_details.dart";
import "package:proxima/models/ui/map_pin_details.dart";
import "package:proxima/services/sensors/geolocation_service.dart";
import "package:proxima/viewmodels/map/map_pin_view_model.dart";
import "package:proxima/viewmodels/map/map_view_model.dart";
import "package:proxima/views/components/async/error_alert.dart";
import "package:proxima/views/pages/home/content/map/components/map_pin_pop_up.dart";

/// This widget displays the Google Map
class PostMap extends ConsumerWidget {
  final MapDetails mapInfo;

  static const mapPinPopUpKey = Key("mapPinPopUp");

  static const postMapKey = Key("postMap");
  static const followButtonKey = Key("followButton");

  const PostMap({
    super.key,
    required this.mapInfo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This provider is used to get information about the map.
    final mapNotifier = ref.watch(mapViewModelProvider.notifier);

    // This provider is used to get the list of map pins.
    final mapPinsAsync = ref.watch(mapPinViewModelProvider);

    // This provider is used to get the live location of the user.
    final positionValue = ref.watch(livePositionStreamProvider);

    //Set of markers to be displayed on the map
    Set<Marker> markers = {};

    Marker mapPinDetailsToMarker(MapPinDetails pin) {
      return Marker(
        markerId: pin.id,
        position: pin.position,
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return MapPinPopUp(
                key: mapPinPopUpKey,
                mapPinPopUpDetails: pin.mapPopUpDetails,
              );
            },
          );
        },
      );
    }

    // This will redraw the circle and update camera when the user's position changes.
    positionValue.when(
      data: (geoPoint) {
        LatLng userPosition = LatLng(geoPoint!.latitude, geoPoint.longitude);
        mapNotifier.redrawCircle(userPosition);
        mapNotifier.updateCamera(userPosition);
      },
      error: (error, _) {
        //Pop up an error dialog if an error occurs

        //ignore the location service disabled exception
        //because we are already handling it in the mapPinViewModel
        if (error is! LocationServiceDisabledException) {
          final dialog = ErrorAlert(error: error);
          WidgetsBinding.instance.addPostFrameCallback((timestamp) {
            showDialog(context: context, builder: dialog.build);
          });
        }
      },
      loading: () => (),
    );

    mapPinsAsync.when(
      data: (data) {
        markers.clear();
        for (final pin in data) {
          markers.add(
            mapPinDetailsToMarker(pin),
          );
        }
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

    final followButton = FloatingActionButton(
      key: followButtonKey,
      onPressed: () {
        // Center the camera on the user's position and follow
        positionValue.whenData((geoPoint) {
          LatLng userPosition = LatLng(geoPoint!.latitude, geoPoint.longitude);
          mapNotifier.enableFollowUser();
          mapNotifier.updateCamera(userPosition);
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
        zoom: MapViewModel.initialZoomLevel,
      ),
      circles: mapNotifier.circles,
      markers: markers,
      onMapCreated: mapNotifier.onMapCreated,
    );

    return Expanded(
      child: Listener(
        onPointerDown: (_) => mapNotifier.disableFollowUser(),
        child: Stack(
          children: [
            googleMap,
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: followButton,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
