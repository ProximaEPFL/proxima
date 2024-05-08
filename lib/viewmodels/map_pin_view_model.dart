import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/map_pin.dart";

// This provider is used to store the list of map pins that are displayed in the map page.
final mapPinProvider = Provider<List<MapPin>>((ref) {
  return List.empty();
});
