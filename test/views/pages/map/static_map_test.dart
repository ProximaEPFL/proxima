import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:mockito/mockito.dart";
import "package:proxima/views/home_content/map/map_screen.dart";
import "package:proxima/views/home_content/map/post_map.dart";
import "package:proxima/views/sort_option_widgets/feed_sort_option/map_selection_option_chips.dart";
import "package:proxima/views/sort_option_widgets/feed_sort_option/map_selection_options.dart";
import "../../../mocks/data/geopoint.dart";
import "../../../mocks/providers/provider_map_page.dart";
import "../../../mocks/services/mock_geo_location_service.dart";

void main() {
  late ProviderScope mapWidget;
  late MockGeoLocationService geoLocationService;

  setUp(() async {
    geoLocationService = MockGeoLocationService();

    mapWidget = newMapPageProvider(geoLocationService);
  });

  group("Widgets display", () {
    testWidgets("Display map, chips, and divider", (tester) async {
      GeoPoint testPoint = userPosition0;
      when(geoLocationService.getCurrentPosition()).thenAnswer(
        (_) => Future.value(testPoint),
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
