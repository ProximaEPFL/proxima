import "package:google_maps_flutter/google_maps_flutter.dart";

class MockMarkers {
  Set<Marker> mockMarkers = {};

  LatLng currentPosition;

  MockMarkers(this.currentPosition)
      : mockMarkers = {
          Marker(
            markerId: const MarkerId("1"),
            position: LatLng(
              currentPosition.latitude + 0.005,
              currentPosition.longitude - 0.004,
            ),
          ),
          Marker(
            markerId: const MarkerId("2"),
            position: LatLng(
              currentPosition.latitude - 0.005,
              currentPosition.longitude + 0.003,
            ),
          ),
          Marker(
            markerId: const MarkerId("3"),
            position: LatLng(
              currentPosition.latitude - 0.008,
              currentPosition.longitude,
            ),
          ),
        };
}
