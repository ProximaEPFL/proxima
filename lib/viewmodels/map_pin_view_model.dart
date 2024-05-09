import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/map_pin.dart";

class MapPinViewModel extends AsyncNotifier<List<MapPin>> {
  @override
  Future<List<MapPin>> build() async {
    // TODO: implement build
    return List.empty();
  }
}

// This provider is used to store the list of map pins that are displayed in the map page.
final mapPinProvider = AsyncNotifierProvider<MapPinViewModel, List<MapPin>>(
  () => MapPinViewModel(),
);
