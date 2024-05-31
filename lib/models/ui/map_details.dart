import "package:google_maps_flutter/google_maps_flutter.dart";

/// Information about how the map should be displayed.
class MapDetails {
  const MapDetails({
    required this.initialLocation,
  });

  /// The initial location of the map. Used to set the initial camera position
  final LatLng initialLocation;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MapDetails && other.initialLocation == initialLocation;
  }

  @override
  int get hashCode => initialLocation.hashCode;
}
