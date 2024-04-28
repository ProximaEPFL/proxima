import "dart:math";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:mockito/mockito.dart";
import "package:proxima/utils/ui/error_alert.dart";
import "package:proxima/views/home_content/map/map_screen.dart";
import "package:proxima/views/navigation/bottom_navigation_bar/navigation_bar_routes.dart";
import "package:proxima/views/navigation/bottom_navigation_bar/navigation_bottom_bar.dart";

import "../../../mocks/data/geopoint.dart";
import "../../../mocks/providers/provider_homepage.dart";
import "../../../mocks/providers/provider_map_page.dart";
import "../../../mocks/services/mock_geo_location_service.dart";
import "../../../mocks/services/mock_post_repository_service.dart";

void main() {
  late ProviderScope nonEmptyHomePageWidget;
  late ProviderScope mapPageNoGPSWidget;
  late MockGeoLocationService geoLocationService;
  late MockPostRepositoryService postRepositoryProvider;

  setUp(() async {
    geoLocationService = MockGeoLocationService();
    postRepositoryProvider = MockPostRepositoryService();

    nonEmptyHomePageWidget = locationHomePageProvider(geoLocationService);

    mapPageNoGPSWidget =
        newMapPageNoGPS(geoLocationService, postRepositoryProvider);
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

  group("Errors handling", () {
    testWidgets("Display error message when location services are disabled",
        (tester) async {
      await tester.pumpWidget(mapPageNoGPSWidget);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.textContaining("Location services are disabled."),
          findsOneWidget);
      // find ok button
      final okButton = find.byKey(ErrorAlert.okButtonKey);
      expect(okButton, findsOneWidget);
      await tester.tap(okButton);
      await tester.pumpAndSettle();

      //find the refresh button
      final refreshButton = find.byKey(MapScreen.refreshButtonKey);
      expect(refreshButton, findsOneWidget);
      await tester.tap(refreshButton);
      await tester.pumpAndSettle();
    });
  });
}
