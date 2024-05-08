import "package:flutter_test/flutter_test.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:proxima/models/ui/map_pin.dart";

void main() {
  group("Map pin testing", () {
    test("hash overrides correctly", () {
      MapPin mapPin = MapPin(
        id: "1",
        position: const LatLng(0, 0),
        callbackFunction: () {},
      );

      final expectedHash = Object.hash(
        mapPin.id,
        mapPin.position,
        mapPin.callbackFunction,
      );

      final actualHash = mapPin.hashCode;

      expect(actualHash, expectedHash);
    });

    test("equality overrides correctly", () {
      //both pin need to have the same method, not just two different methods that have the same logic
      testFunction() {}

      MapPin mapPin = MapPin(
        id: "1",
        position: const LatLng(0, 0),
        callbackFunction: testFunction(),
      );

      MapPin mapPinCopy = MapPin(
        id: "1",
        position: const LatLng(0, 0),
        callbackFunction: testFunction(),
      );

      expect(mapPin, mapPinCopy);
    });

    test("inequality test on id", () {
      testFunction() {}

      MapPin mapPin = MapPin(
        id: "1",
        position: const LatLng(0, 0),
        callbackFunction: testFunction(),
      );

      MapPin mapPinCopy = MapPin(
        id: "2",
        position: const LatLng(0, 0),
        callbackFunction: testFunction(),
      );

      expect(mapPin == mapPinCopy, false);
    });

    test("inequality test on position", () {
      testFunction() {}

      MapPin mapPin = MapPin(
        id: "1",
        position: const LatLng(0, 0),
        callbackFunction: testFunction(),
      );

      MapPin mapPinCopy = MapPin(
        id: "1",
        position: const LatLng(1, 1),
        callbackFunction: testFunction(),
      );

      expect(mapPin == mapPinCopy, false);
    });
  });
}
