import "package:google_maps_flutter/google_maps_flutter.dart";

class MockMarkers {
  Set<Marker> mockMarkers = {};

  LatLng currentPosition;

  MockMarkers(this.currentPosition)
      : mockMarkers = {
          Marker(
            markerId: const MarkerId("1"),
            position: LatLng(
              currentPosition.latitude + 0.0005,
              currentPosition.longitude - 0.0004,
            ),
          ),
          Marker(
            markerId: const MarkerId("2"),
            position: LatLng(
              currentPosition.latitude - 0.0005,
              currentPosition.longitude + 0.0003,
            ),
          ),
          Marker(
            markerId: const MarkerId("3"),
            position: LatLng(
              currentPosition.latitude - 0.0008,
              currentPosition.longitude,
            ),
          ),
        };
}
