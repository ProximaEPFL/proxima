import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:mockito/mockito.dart";
import "package:proxima/views/home_content/map_feed/map_feed.dart";
import "package:proxima/views/home_content/map_feed/maps/nearby_posts_map.dart";
import "package:proxima/views/sort_option_widgets/feed_sort_option/map_sort_option_chips.dart";
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

      expect(find.byKey(MapFeedState.mapScreenKey), findsOneWidget);
      expect(find.byKey(MapFeedState.dividerKey), findsOneWidget);

      expect(find.byKey(const Key("Nearby")), findsOneWidget);
      expect(find.byKey(const Key("Heat map")), findsOneWidget);
      expect(find.byKey(const Key("My posts")), findsOneWidget);
      expect(find.byKey(const Key("Challenges")), findsOneWidget);

      expect(find.byKey(MapSortOptionChips.sortOptionsKey), findsOneWidget);

      expect(find.byKey(NearbyPostsMapState.nearbyPostsMapKey), findsOneWidget);
    });
  });
}
