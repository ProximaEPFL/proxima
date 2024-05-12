import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/map_pin_details.dart";

// This view model is used to create and store
// the markers of the map given a list of [MapPinDetails].
class MapMarkersViewModel extends Notifier<void> {
  @override
  void build() {}

  final Set<Marker> _markers = {};
  // Getter for the markers
  Set<Marker> get markers => _markers;

  void redrawMarkers(List<MapPinDetails> pinList) {
    _markers.clear();
    for (final pin in pinList) {
      _markers.add(
        Marker(
          markerId: pin.id,
          position: pin.position,
          onTap: pin.callbackFunction,
        ),
      );
    }
  }
}

final mapMarkersViewModelProvider = NotifierProvider<MapMarkersViewModel, void>(
  () => MapMarkersViewModel(),
);
