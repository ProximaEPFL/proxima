import "package:flutter_test/flutter_test.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:proxima/models/ui/map_pin_details.dart";

import "../../mocks/data/latLng.dart";

void main() {
  group("Map pin testing", () {
    testFunction() {}
    testFunctionDifferent() {}
    test("hash overrides correctly", () {
      MapPinDetails mapPin = MapPinDetails(
        id: const MarkerId("1"),
        position: latLngLocation0,
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

      MapPinDetails mapPin = MapPinDetails(
        id: const MarkerId("1"),
        position: latLngLocation0,
        callbackFunction: testFunction,
      );

      MapPinDetails mapPinCopy = MapPinDetails(
        id: const MarkerId("1"),
        position: latLngLocation0,
        callbackFunction: testFunction,
      );

      expect(mapPin, mapPinCopy);
    });

    test("inequality test on id", () {
      MapPinDetails mapPin = MapPinDetails(
        id: const MarkerId("1"),
        position: latLngLocation0,
        callbackFunction: testFunction,
      );

      MapPinDetails mapPinDifferent = MapPinDetails(
        id: const MarkerId("2"),
        position: latLngLocation0,
        callbackFunction: testFunction,
      );

      expect(mapPin == mapPinDifferent, false);
    });

    test("inequality test on position", () {
      MapPinDetails mapPin = MapPinDetails(
        id: const MarkerId("1"),
        position: latLngLocation0,
        callbackFunction: testFunction,
      );

      MapPinDetails mapPinDifferent = MapPinDetails(
        id: const MarkerId("1"),
        position: latLngLocation1,
        callbackFunction: testFunction,
      );

      expect(mapPin == mapPinDifferent, false);
    });

    test("inequality test on callback function", () {
      MapPinDetails mapPin = MapPinDetails(
        id: const MarkerId("1"),
        position: latLngLocation0,
        callbackFunction: testFunction,
      );

      MapPinDetails mapPinDifferent = MapPinDetails(
        id: const MarkerId("1"),
        position: latLngLocation0,
        callbackFunction: testFunctionDifferent,
      );

      expect(mapPin == mapPinDifferent, false);
    });
  });
}
