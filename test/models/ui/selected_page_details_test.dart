import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/ui/selected_page_details.dart";
import "package:proxima/views/navigation/bottom_navigation_bar/navigation_bar_routes.dart";

import "../../mocks/data/geopoint.dart";

void main() {
  test("Equality overrides correctly", () {
    const feedPageDetails = SelectedPageDetails(
      route: NavigationBarRoutes.feed,
    );

    const feedPageDetailsCopy = SelectedPageDetails(
      route: NavigationBarRoutes.feed,
    );

    const mapPageDetails = SelectedPageDetails(
      route: NavigationBarRoutes.map,
      args: userPosition0,
    );

    const mapPageDetailsCopy = SelectedPageDetails(
      route: NavigationBarRoutes.map,
      args: userPosition0,
    );

    expect(feedPageDetails, equals(feedPageDetailsCopy));
    expect(mapPageDetails, equals(mapPageDetailsCopy));
    expect(feedPageDetails, isNot(equals(mapPageDetails)));
  });

  test("Hash overrides correctly", () {
    final expectedHash = Object.hash(
      NavigationBarRoutes.feed,
      null,
    );

    final actualHash = const SelectedPageDetails(
      route: NavigationBarRoutes.feed,
    ).hashCode;
    expect(actualHash, equals(expectedHash));
  });
}
