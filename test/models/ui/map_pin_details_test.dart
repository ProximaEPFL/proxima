import "package:flutter_test/flutter_test.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:proxima/models/ui/map_pin_details.dart";
import "package:proxima/models/ui/map_pop_up_details.dart";

import "../../mocks/data/latlng.dart";

void main() {
  group("Map pin testing", () {
    test("hash overrides correctly", () {
      MapPinDetails mapPin = const MapPinDetails(
        id: MarkerId("1"),
        position: latLngLocation0,
        mapPopUpDetails: MapPopUpDetails(
          title: "Title",
          description: "Description",
        ),
      );

      final expectedHash = Object.hash(
        mapPin.id,
        mapPin.position,
        mapPin.mapPopUpDetails,
      );

      final actualHash = mapPin.hashCode;

      expect(actualHash, expectedHash);
    });

    test("equality overrides correctly", () {
      //both pin need to have the same method, not just two different methods that have the same logic

      MapPinDetails mapPin = const MapPinDetails(
        id: MarkerId("1"),
        position: latLngLocation0,
        mapPopUpDetails: MapPopUpDetails(
          title: "Title",
          description: "Description",
        ),
      );

      MapPinDetails mapPinCopy = const MapPinDetails(
        id: MarkerId("1"),
        position: latLngLocation0,
        mapPopUpDetails: MapPopUpDetails(
          title: "Title",
          description: "Description",
        ),
      );

      expect(mapPin, mapPinCopy);
    });

    test("inequality test on id", () {
      MapPinDetails mapPin = const MapPinDetails(
        id: MarkerId("1"),
        position: latLngLocation0,
        mapPopUpDetails: MapPopUpDetails(
          title: "Title",
          description: "Description",
        ),
      );

      MapPinDetails mapPinDifferent = const MapPinDetails(
        id: MarkerId("2"),
        position: latLngLocation0,
        mapPopUpDetails: MapPopUpDetails(
          title: "Title",
          description: "Description",
        ),
      );

      expect(mapPin == mapPinDifferent, false);
    });

    test("inequality test on position", () {
      MapPinDetails mapPin = const MapPinDetails(
        id: MarkerId("1"),
        position: latLngLocation0,
        mapPopUpDetails: MapPopUpDetails(
          title: "Title",
          description: "Description",
        ),
      );

      MapPinDetails mapPinDifferent = const MapPinDetails(
        id: MarkerId("1"),
        position: latLngLocation1,
        mapPopUpDetails: MapPopUpDetails(
          title: "Title",
          description: "Description",
        ),
      );

      expect(mapPin == mapPinDifferent, false);
    });

    test("inequality test on map pop up details", () {
      MapPinDetails mapPin = const MapPinDetails(
        id: MarkerId("1"),
        position: latLngLocation0,
        mapPopUpDetails: MapPopUpDetails(
          title: "Title1",
          description: "Description",
        ),
      );

      MapPinDetails mapPinDifferent = const MapPinDetails(
        id: MarkerId("1"),
        position: latLngLocation0,
        mapPopUpDetails: MapPopUpDetails(
          title: "Title2",
          description: "Different Description",
        ),
      );

      expect(mapPin == mapPinDifferent, false);
    });
  });
}
