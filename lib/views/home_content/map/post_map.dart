import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/map_info.dart";
import "package:proxima/services/geolocation_service.dart";
import "package:proxima/viewmodels/home_view_model.dart";

class PostMap extends ConsumerWidget {
  final MapInfo mapInfo;

  static const postMapKey = Key("postMap");

  const PostMap({
    super.key,
    required this.mapInfo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPosition = ref.watch(liveLocationServiceProvider);

    GoogleMapController? mapController;

    currentPosition.when(
      data: (data) {
        debugPrint("Live location: ${data!.latitude}, ${data.longitude}");
        if (mapController == null) return;
        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(data.latitude, data.longitude),
              zoom: 17.5,
            ),
          ),
        );
      },
      error: (error, _) {
        throw Exception("Live location error: $error");
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
          target: mapInfo.currentLocation,
          zoom: 17.5,
        ),
        circles: {
          Circle(
            circleId: const CircleId("1"),
            center: mapInfo.currentLocation,
            radius: HomeViewModel.kmPostRadius * 1000,
            fillColor: Colors.black26,
            strokeWidth: 0,
          ),
        },
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
      ),
    );
  }
}
