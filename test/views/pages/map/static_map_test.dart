import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:geolocator/geolocator.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:mockito/mockito.dart";
import "package:proxima/services/sensors/geolocation_service.dart";
import "package:proxima/views/components/options/map/map_selection_option_chips.dart";
import "package:proxima/views/components/options/map/map_selection_options.dart";
import "package:proxima/views/pages/home/content/map/map_screen.dart";
import "package:proxima/views/pages/home/content/map/post_map.dart";

import "../../../mocks/data/map_pin.dart";
import "../../../mocks/providers/provider_map_page.dart";
import "../../../mocks/services/mock_geolocator_platform.dart";

void main() {
  late ProviderScope mapWidget;
  late ProviderScope mapWidgetWithPins;
  late MockGeolocatorPlatform mockGeolocator;
  late GeolocationService geoLocationService;
  late Set<GeoPoint?> geoPoints;

  setUp(() async {
    mockGeolocator = MockGeolocatorPlatform();
    geoLocationService = GeolocationService(geoLocator: mockGeolocator);
    geoPoints = <GeoPoint>{
      const GeoPoint(37.4219983, -122.084),
      const GeoPoint(38.4219983, -123.084),
    };
    mapWidget = newMapPageProvider(geoLocationService, geoPoints);
    mapWidgetWithPins = newMapPageWithPins(geoLocationService);

    const latitude = 37.4219983;
    const longitude = -122.084;

    when(mockGeolocator.isLocationServiceEnabled())
        .thenAnswer((_) async => true);
    when(mockGeolocator.checkPermission())
        .thenAnswer((_) async => LocationPermission.always);
    when(
      mockGeolocator.getCurrentPosition(
        locationSettings: geoLocationService.locationSettings,
      ),
    ).thenAnswer(
      (_) async => getSimplePosition(latitude, longitude),
    );
    when(
      mockGeolocator.getPositionStream(
        locationSettings: geoLocationService.locationSettings,
      ),
    ).thenAnswer(
      (_) => Stream.fromIterable([
        getSimplePosition(latitude, longitude),
        getSimplePosition(latitude + 1, longitude),
      ]),
    );
  });

  group("Widgets display", () {
    testWidgets("Display map, chips, and divider", (tester) async {
      await tester.pumpWidget(mapWidget);
      await tester.pumpAndSettle();

      expect(find.byKey(MapScreen.mapScreenKey), findsOneWidget);
      expect(find.byKey(MapScreen.dividerKey), findsOneWidget);

      // Extract keys from the MapSelectionOptions enum
      final keys =
          MapSelectionOptions.values.map((option) => Key(option.name)).toList();

      // Verify that each ChoiceChip is found by its key
      for (final key in keys) {
        expect(find.byKey(key), findsOneWidget);
      }

      expect(
        find.byKey(MapSelectionOptionChips.selectOptionsKey),
        findsOneWidget,
      );

      expect(
        find.byKey(PostMap.postMapKey),
        findsOneWidget,
      );
    });

    testWidgets("Display FAB", (tester) async {
      await tester.pumpWidget(mapWidget);
      await tester.pumpAndSettle();

      final followButton = find.byKey(PostMap.followButtonKey);
      expect(followButton, findsOneWidget);
      await tester.tap(followButton);
    });
  });

  group("Pins display", () {
    testWidgets("Map receives pins", (tester) async {
      await tester.pumpWidget(mapWidgetWithPins);
      await tester.pumpAndSettle();

      // Verify that the map screen is displayed
      expect(find.byKey(MapScreen.mapScreenKey), findsOneWidget);

      //check that Set<Marker> markers is not empty
      final markers = tester
          .widget<GoogleMap>(
            find.byKey(PostMap.postMapKey),
          )
          .markers;

      expect(markers, isNotEmpty);

      //check that the markers are displayed on the map have the correct data
      for (final pin in MapPinGenerator.generateMapPins(5)) {
        expect(
          markers,
          contains(
            isA<Marker>()
                .having(
                  (marker) => marker.markerId,
                  "markerId",
                  pin.id,
                )
                .having((marker) => marker.position, "position", pin.position),
          ),
        );
      }
    });
  });
}
