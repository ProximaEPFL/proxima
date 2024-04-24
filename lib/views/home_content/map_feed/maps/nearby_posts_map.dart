import "package:flutter/material.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/views/home_content/map_feed/maps/mock_markers.dart";

class NearbyPostsMap extends ConsumerStatefulWidget {
  final LatLng currentPosition;

  final double currentZoom;

  final double radius;

  final Key mapKey = const Key("Nearby posts map");

  const NearbyPostsMap({
    super.key,
    required this.currentPosition,
    required this.currentZoom,
    required this.radius,
  });

  @override
  NearbyPostsMapState createState() => NearbyPostsMapState();
}

class NearbyPostsMapState extends ConsumerState<NearbyPostsMap> {
  //key for testing
  static const nearbyPostsMapKey = Key("Nearby posts map");

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //TODO: replace mock markers with real nearby posts
    Set<Marker> mockMarkers = MockMarkers(widget.currentPosition).mockMarkers;
    return GoogleMap(
      key: nearbyPostsMapKey,
      initialCameraPosition: CameraPosition(
        target: widget.currentPosition,
        zoom: widget.currentZoom,
      ),
      //the user sees their current location on the map
      myLocationEnabled: true,
      //no need for this button because the user can't scroll the map
      myLocationButtonEnabled: false,
      zoomGesturesEnabled: false,
      //no need for these gestures because the user can't scroll the map
      zoomControlsEnabled: false,
      //we can't scroll the map
      scrollGesturesEnabled: false,
      circles: {
        Circle(
          circleId: const CircleId("1"),
          center: widget.currentPosition,
          radius: widget.radius * 1000,
          fillColor: Colors.black12,
          strokeWidth: 0,
        ),
      },
      markers: mockMarkers,
    );
  }
}
