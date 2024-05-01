import "package:flutter_test/flutter_test.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:proxima/models/ui/map_info.dart";
import "package:proxima/views/option_widgets/map/map_selection_option.dart";

void main() {
  group("hash and == works", () {
    test("hash", () {
      const mapInfo1 = MapInfo(
        currentLocation: LatLng(0, 0),
        selectOption: MapSelectionOptions.nearby,
      );

      final expectedHash = Object.hash(
        mapInfo1.currentLocation,
        mapInfo1.selectOption,
      );

      final actualHash = mapInfo1.hashCode;

      expect(actualHash, expectedHash);
    });

    test("==", () {
      const mapInfo1 = MapInfo(
        currentLocation: LatLng(0, 0),
        selectOption: MapSelectionOptions.nearby,
      );
      const mapInfo2 = MapInfo(
        currentLocation: LatLng(1, 1),
        selectOption: MapSelectionOptions.nearby,
      );
      const mapInfo3 = MapInfo(
        currentLocation: LatLng(0, 0),
        selectOption: MapSelectionOptions.nearby,
      );

      expect(mapInfo1 == mapInfo2, isFalse);
      expect(mapInfo1 == mapInfo3, isTrue);
    });
  });
}
