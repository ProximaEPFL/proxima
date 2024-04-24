import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:mockito/mockito.dart";
import "package:proxima/views/navigation/bottom_navigation_bar/navigation_bar_routes.dart";
import "package:proxima/views/navigation/bottom_navigation_bar/navigation_bottom_bar.dart";

import "../../../mocks/data/geopoint.dart";
import "../../../mocks/providers/provider_homepage.dart";
import "../../../mocks/services/mock_geo_location_service.dart";

void main() {
  late ProviderScope nonEmptyHomePageWidget;
  late MockGeoLocationService geoLocationService;

  setUp(() async {
    geoLocationService = MockGeoLocationService();

    nonEmptyHomePageWidget = locationHomePageProvider(geoLocationService);
  });

  group("Navigation", () {
    testWidgets("Navigation to the map screen", (tester) async {
      await tester.pumpWidget(nonEmptyHomePageWidget);
      await tester.pumpAndSettle();

      //Click on the last element of the bottombar
      final bottomBar = find.byKey(NavigationBottomBar.navigationBottomBarKey);
      await tester.tap(
        find.descendant(
          of: bottomBar,
          matching: find
              .byType(NavigationDestination)
              .at(NavigationbarRoutes.map.index),
        ),
      );

      GeoPoint testPoint = userPosition0;
      when(geoLocationService.getCurrentPosition()).thenAnswer(
        (_) => Future.value(testPoint),
      );

      await tester.pumpAndSettle();
    });
  });
}
