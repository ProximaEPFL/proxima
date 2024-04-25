import "package:flutter/material.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:proxima/viewmodels/map_view_model.dart";
import "package:proxima/views/home_content/map/mock_markers.dart";

class PostMap extends StatelessWidget {
  final MapInfo mapInfo;
  final Function(GoogleMapController) onMapCreated;

  static const postMapKey = Key("PostMap");

  const PostMap({
    super.key,
    required this.mapInfo,
    required this.onMapCreated,
  });

  @override
  Widget build(BuildContext context) {
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
            radius: 100,
            fillColor: Colors.black12,
            strokeWidth: 0,
          ),
        },
        markers: MockMarkers(mapInfo.currentLocation).mockMarkers,
        onMapCreated: onMapCreated,
      ),
    );
  }
}
