import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/map_info.dart";
import "package:proxima/views/home_content/map/map_screen.dart";
import "package:proxima/views/home_content/map/post_map.dart";
import "package:proxima/views/option_widgets/map/map_selection_option.dart";
import "package:proxima/views/option_widgets/map/map_selection_option_chips.dart";

import "../../../mocks/providers/provider_map_page.dart";

void main() {
  late ProviderScope mapWidget;
  setUp(() async {
    mapWidget = newMapPageProvider();
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
  });

  group("hash and == works", () {
    test("hash", () {
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

      expect(mapInfo1.hashCode, isNot(mapInfo2.hashCode));
      expect(mapInfo1.hashCode, mapInfo3.hashCode);
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
