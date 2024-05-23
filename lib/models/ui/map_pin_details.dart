import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:proxima/models/ui/map_pop_up_details.dart";

/// Custom map pin class used to display pins on the map
class MapPinDetails {
  const MapPinDetails({
    required this.id,
    required this.position,
    required this.mapPopUpDetails,
  });

  /// Unique id that identifies the pin
  /// (must be unique for each pin)
  final MarkerId id;

  /// Position of the pin on the map
  final LatLng position;

  /// Callback function that is called when we click on the pin
  final MapPopUpDetails mapPopUpDetails;

  @override
  bool operator ==(Object other) {
    return other is MapPinDetails &&
        other.id == id &&
        other.position == position &&
        other.mapPopUpDetails == mapPopUpDetails;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      position,
      mapPopUpDetails,
    );
  }
}
