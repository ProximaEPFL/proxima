import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/ui/map_details.dart";

import "../../mocks/data/latlng.dart";

void main() {
  group("hash and == works", () {
    test("hash", () {
      const mapInfo1 = MapDetails(
        initialLocation: latLngLocation0,
      );

      final expectedHash = mapInfo1.initialLocation.hashCode;

      final actualHash = mapInfo1.hashCode;

      expect(actualHash, expectedHash);
    });

    test("==", () {
      const mapInfo1 = MapDetails(
        initialLocation: latLngLocation0,
      );
      const mapInfo2 = MapDetails(
        initialLocation: latLngLocation1,
      );
      const mapInfo3 = MapDetails(
        initialLocation: latLngLocation0,
      );

      expect(mapInfo1 == mapInfo2, isFalse);
      expect(mapInfo1 == mapInfo3, isTrue);
    });
  });
}
