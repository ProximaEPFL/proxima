import "package:google_maps_flutter/google_maps_flutter.dart";

//custom map pin class used to display pins on the map
class MapPin {
  const MapPin({
    required this.id,
    required this.position,
    required this.callbackFunction,
  });

  final String id;
  final LatLng position;
  final void Function()? callbackFunction;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MapPin &&
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
