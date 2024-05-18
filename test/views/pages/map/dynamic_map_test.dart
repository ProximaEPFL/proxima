import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:mockito/mockito.dart";
import "package:proxima/viewmodels/option_selection/map_selection_options_view_model.dart";
import "package:proxima/views/pages/home/content/map/map_screen.dart";

import "../../../mocks/data/geopoint.dart";
import "../../../mocks/providers/provider_map_page.dart";
import "../../../mocks/services/mock_geo_location_service.dart";

void main() {
  late MockGeolocationService geoLocationService;
  late ProviderScope mapPage;

  late FakeFirebaseFirestore fakeFirestore;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    geoLocationService = MockGeolocationService();

    mapPage = mapScreenFakeFirestoreProvider(fakeFirestore, geoLocationService);
    when(geoLocationService.getCurrentPosition()).thenAnswer(
      (_) => Future.value(userPosition0),
    );
    when(geoLocationService.getPositionStream()).thenAnswer(
      (_) => Stream.value(userPosition0),
    );
  });

  group("Option selection", () {
    testWidgets("Correct default option", (tester) async {
      final container = await (WidgetTester tester) async {
        await tester.pumpWidget(mapPage);
        await tester.pumpAndSettle();

        final element = tester.element(find.byType(MapScreen));
        return ProviderScope.containerOf(element);
      }(tester);

      final currentOption = container.read(
        mapSelectionOptionsViewModelProvider,
      );
      expect(
        currentOption,
        equals(MapSelectionOptionsViewModel.defaultMapOption),
      );
    });
  });
}
