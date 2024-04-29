import "package:flutter/material.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:proxima/viewmodels/home_view_model.dart";
import "package:proxima/viewmodels/map_view_model.dart";

class PostMap extends StatelessWidget {
  final MapInfo mapInfo;

  static const postMapKey = Key("postMap");

  const PostMap({
    super.key,
    required this.mapInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GoogleMap(
        key: postMapKey,
        mapType: MapType.normal,
        myLocationButtonEnabled: false,
        myLocationEnabled: false,
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
      ),
    );
  }
}
