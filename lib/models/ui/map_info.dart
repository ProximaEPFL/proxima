import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:proxima/views/option_widgets/map/map_selection_option.dart";

class MapInfo {
  const MapInfo({
    required this.currentLocation,
    required this.selectOption,
  });
  final LatLng currentLocation;
  final MapSelectionOptions selectOption;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MapInfo &&
        other.currentLocation == currentLocation &&
        other.selectOption == selectOption;
  }

  @override
  int get hashCode => Object.hash(
        currentLocation,
        selectOption,
      );
}
