import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:flutter_test/flutter_test.dart";
import "package:geolocator/geolocator.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:mockito/mockito.dart";
import "package:proxima/services/geolocation_service.dart";
import "package:proxima/views/home_content/map/map_screen.dart";
import "package:proxima/views/home_content/map/post_map.dart";
import "package:proxima/views/option_widgets/map/map_selection_option.dart";
import "package:proxima/views/option_widgets/map/map_selection_option_chips.dart";
import "../../../mocks/providers/provider_map_page.dart";
import "../../../mocks/services/mock_geolocator_platform.dart";

void main() {
  late ProviderScope mapWidget;
  late MockGeolocatorPlatform mockGeolocator;
  late GeoLocationService geoLocationService;
  late Set<GeoPoint?> geoPoints;
  setUp(() async {
    mockGeolocator = MockGeolocatorPlatform();
    geoLocationService = GeoLocationService(geoLocator: mockGeolocator);
    geoPoints = <GeoPoint>{
      const GeoPoint(37.4219983, -122.084),
      const GeoPoint(38.4219983, -123.084),
    };
    mapWidget = newMapPageProvider(geoLocationService, geoPoints);
  });

  group("Widgets display", () {
    testWidgets("Display map, chips, and divider", (tester) async {
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
  });
}
