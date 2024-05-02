import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:proxima/views/option_widgets/map/map_selection_option.dart";

class MapInfo {
  const MapInfo({
    required this.initialLocation,
    required this.selectOption,
  });
  final LatLng initialLocation;
  final MapSelectionOptions selectOption;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MapInfo &&
        other.initialLocation == initialLocation &&
        other.selectOption == selectOption;
  }

  @override
  int get hashCode => Object.hash(
        initialLocation,
        selectOption,
      );
}
