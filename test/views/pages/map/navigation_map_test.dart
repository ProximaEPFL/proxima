import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/utils/ui/error_alert.dart";
import "package:proxima/views/home_content/map/map_screen.dart";
import "package:proxima/views/navigation/bottom_navigation_bar/navigation_bar_routes.dart";
import "package:proxima/views/navigation/bottom_navigation_bar/navigation_bottom_bar.dart";

import "../../../mocks/providers/provider_homepage.dart";
import "../../../mocks/providers/provider_map_page.dart";

void main() {
  late ProviderScope mapPageNoGPSWidget;

  setUp(() async {
    mapPageNoGPSWidget = newMapPageNoGPS();
  });

  group("Navigation", () {
    testWidgets("Navigation to the map screen", (tester) async {
      await tester.pumpWidget(emptyHomePageProvider);
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
      await tester.pumpAndSettle();
      expect(find.byKey(MapScreen.mapScreenKey), findsOneWidget);
    });
  });

  group("Errors handling", () {
    testWidgets("Display error message when location services are disabled",
        (tester) async {
      await tester.pumpWidget(mapPageNoGPSWidget);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.textContaining("Location services are disabled."),
        findsOneWidget,
      );
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
