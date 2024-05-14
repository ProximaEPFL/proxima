import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/map_pin_details.dart";

// This view model is used to create and store
// the markers of the map given a list of [MapPinDetails].
class MapMarkersViewModel extends Notifier<void> {
  @override
  void build() {
    //Nothing is done here
  }

  final Set<Marker> _markers = {};
  // Getter for the markers
  Set<Marker> get markers => _markers;
// This method will update the markers stored in the view model
  void updateMarkers(List<MapPinDetails> pinList) {
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
