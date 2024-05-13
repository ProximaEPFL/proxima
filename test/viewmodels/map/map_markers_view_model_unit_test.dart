import "package:flutter_test/flutter_test.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/map/map_markers_view_model.dart";

import "../../mocks/data/map_pin.dart";

void main() {
  group("Map Markers View Model unit testing", () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    test("Initially no markers are present", () {
      final markers =
          container.read(mapMarkersViewModelProvider.notifier).markers;

      expect(markers, isEmpty);
    });

    test("Check correct tranformation to markers", () {
      // Get the notifier
      final mapMarkersNotifier =
          container.read(mapMarkersViewModelProvider.notifier);

      // Generate some pins
      final pins = MapPinGenerator.generateMapPins(5);

      // Store the pins (Create the markers)
      mapMarkersNotifier.updateMarkers(pins);

      // Create expected markers
      final expectedMarkers = pins
          .map(
            (pin) => Marker(
              markerId: pin.id,
              position: pin.position,
              onTap: pin.callbackFunction,
            ),
          )
          .toSet();

      // Check that the markers are equal to the one expected
      final markers = mapMarkersNotifier.markers;

      expect(markers, expectedMarkers);
    });

    test("Check that the markers are correctly replaced", () {
      // Get the notifier
      final mapMarkersNotifier =
          container.read(mapMarkersViewModelProvider.notifier);

      const numberOfPinsPerIteration = 5;
      const numberOfIteration = 2;

      // Generate some pins
      final pins = MapPinGenerator.generateMapPins(
        numberOfPinsPerIteration * numberOfIteration,
      );

      for (int i = 0; i < numberOfIteration; i++) {
        // Drop the first numberOfPinsPerIteration * i using sublist
        // and take the next numberOfPinsPerIteration pins.
        final storedPins = pins
            .sublist(numberOfPinsPerIteration * i)
            .take(numberOfPinsPerIteration)
            .toList();

        // Store pins
        mapMarkersNotifier.updateMarkers(storedPins);

        // Create expected markers
        final expectedMarkers = storedPins
            .map(
              (pin) => Marker(
                markerId: pin.id,
                position: pin.position,
                onTap: pin.callbackFunction,
              ),
            )
            .toSet();

        // Check that the markers are equal to the one expected
        final markers = mapMarkersNotifier.markers;

        expect(markers, expectedMarkers);
      }
    });
  });
}
