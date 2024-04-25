import "package:flutter/material.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:proxima/viewmodels/map/map_state.dart";
import "package:proxima/views/home_content/map/mock_markers.dart";

class PostMap extends StatelessWidget {
  final MapState mapState;
  final Function(GoogleMapController) onMapCreated;

  static const postMapKey = Key("PostMap");

  const PostMap({
    super.key,
    required this.mapState,
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
          target: mapState.currentLocation,
          zoom: 17.5,
        ),
        circles: {
          Circle(
            circleId: const CircleId("1"),
            center: mapState.currentLocation,
            radius: 100,
            fillColor: Colors.black12,
            strokeWidth: 0,
          ),
        },
        markers: MockMarkers(mapState.currentLocation).mockMarkers,
        onMapCreated: onMapCreated,
      ),
    );
  }
}
