import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:proxima/views/components/options/map/map_selection_options.dart";

/// Information about how the map should be displayed.
class MapDetails {
  const MapDetails({
    required this.initialLocation,
    required this.selectOption,
  });

  /// The initial location of the map. Used to set the initial camera position
  final LatLng initialLocation;

  /// The option selected by the user. Defines how the map will be displayed
  final MapSelectionOptions selectOption;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MapDetails &&
        other.initialLocation == initialLocation &&
        other.selectOption == selectOption;
  }

  @override
  int get hashCode => Object.hash(
        initialLocation,
        selectOption,
      );
}
