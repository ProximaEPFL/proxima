import "package:flutter_test/flutter_test.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:proxima/models/ui/map_pin.dart";

void main() {
  group("Map pin testing", () {
    testFunction() {}
    testFunctionDifferent() {}
    test("hash overrides correctly", () {
      MapPin mapPin = MapPin(
        id: const MarkerId("1"),
        position: const LatLng(0, 0),
        callbackFunction: testFunction,
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

      MapPin mapPin = MapPin(
        id: const MarkerId("1"),
        position: const LatLng(0, 0),
        callbackFunction: testFunction,
      );

      MapPin mapPinCopy = MapPin(
        id: const MarkerId("1"),
        position: const LatLng(0, 0),
        callbackFunction: testFunction,
      );

      expect(mapPin, mapPinCopy);
    });

    test("inequality test on id", () {
      MapPin mapPin = MapPin(
        id: const MarkerId("1"),
        position: const LatLng(0, 0),
        callbackFunction: testFunction,
      );

      MapPin mapPinDifferent = MapPin(
        id: const MarkerId("2"),
        position: const LatLng(0, 0),
        callbackFunction: testFunction,
      );

      expect(mapPin == mapPinDifferent, false);
    });

    test("inequality test on position", () {
      MapPin mapPin = MapPin(
        id: const MarkerId("1"),
        position: const LatLng(0, 0),
        callbackFunction: testFunction,
      );

      MapPin mapPinDifferent = MapPin(
        id: const MarkerId("1"),
        position: const LatLng(1, 1),
        callbackFunction: testFunction,
      );

      expect(mapPin == mapPinDifferent, false);
    });

    test("inequality test on callback function", () {
      MapPin mapPin = MapPin(
        id: const MarkerId("1"),
        position: const LatLng(0, 0),
        callbackFunction: testFunction,
      );

      MapPin mapPinDifferent = MapPin(
        id: const MarkerId("1"),
        position: const LatLng(0, 0),
        callbackFunction: testFunctionDifferent,
      );

      expect(mapPin == mapPinDifferent, false);
    });
  });
}
