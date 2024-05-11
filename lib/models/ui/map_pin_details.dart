import "package:google_maps_flutter/google_maps_flutter.dart";

/// Custom map pin class used to display pins on the map
class MapPinDetails {
  const MapPinDetails({
    required this.id,
    required this.position,
    required this.callbackFunction,
  });

  /// Unique id that identifies the pin
  /// (must be unique for each pin)
  final MarkerId id;

  /// Position of the pin on the map
  final LatLng position;

  /// Callback function that is called when we click on the pin
  final void Function() callbackFunction;

  @override
  bool operator ==(Object other) {
    return other is MapPinDetails &&
        other.id == id &&
        other.position == position &&
        other.callbackFunction == callbackFunction;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      position,
      callbackFunction,
    );
  }
}
