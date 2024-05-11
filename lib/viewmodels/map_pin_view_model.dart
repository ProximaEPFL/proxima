import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/map_pin_details.dart";

class MapPinViewModel extends AsyncNotifier<List<MapPinDetails>> {
  @override
  Future<List<MapPinDetails>> build() async {
    // TODO: implement build
    return List.empty();
  }
}

// This provider is used to store the list of map pins that are displayed in the map page.
final mapPinProvider = AsyncNotifierProvider<MapPinViewModel, List<MapPinDetails>>(
  () => MapPinViewModel(),
);
