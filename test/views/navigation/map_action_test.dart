import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/selected_page_details.dart";
import "package:proxima/utils/extensions/geopoint_extensions.dart";
import "package:proxima/viewmodels/option_selection/selected_page_view_model.dart";
import "package:proxima/views/components/options/map/map_selection_options.dart";
import "package:proxima/views/navigation/bottom_navigation_bar/navigation_bar_routes.dart";
import "package:proxima/views/navigation/map_action.dart";

import "../../mocks/data/geopoint.dart";
import "../../mocks/data/latlng.dart";

void main() {
  late SelectedPageViewModel selectedPageViewModel;
  late ProviderScope mapActionWidget;

  setUp(() {
    selectedPageViewModel = SelectedPageViewModel();

    mapActionWidget = ProviderScope(
      overrides: [
        selectedPageViewModelProvider.overrideWith(() => selectedPageViewModel),
      ],
      child: const MaterialApp(
        home: MapAction(
          depth: 0,
          mapOption: MapSelectionOptions.myPosts,
          initialLocation: latLngLocation0,
        ),
      ),
    );
  });

  testWidgets("MapAction shows and navigates correctly",
      (WidgetTester tester) async {
    await tester.pumpWidget(mapActionWidget);

    expect(find.byKey(MapAction.mapActionKey), findsOneWidget);

    expect(find.byIcon(Icons.place), findsOneWidget);

    await tester.tap(find.byKey(MapAction.mapActionKey));
    await tester.pumpAndSettle();

    expect(
      selectedPageViewModel.state,
      SelectedPageDetails(
        route: NavigationBarRoutes.map,
        args: userPosition0.toLatLng(),
      ),
    );
  });
}
