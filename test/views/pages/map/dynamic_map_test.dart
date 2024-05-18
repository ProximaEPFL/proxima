import "package:cloud_firestore/cloud_firestore.dart";
import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:mockito/mockito.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/ui/map_pin_details.dart";
import "package:proxima/viewmodels/map/map_pin_view_model.dart";
import "package:proxima/viewmodels/option_selection/map_selection_options_view_model.dart";
import "package:proxima/views/components/options/map/map_selection_option_chips.dart";
import "package:proxima/views/components/options/map/map_selection_options.dart";
import "package:proxima/views/pages/home/content/map/map_screen.dart";

import "../../../mocks/data/firestore_post.dart";
import "../../../mocks/data/firestore_user.dart";
import "../../../mocks/data/geopoint.dart";
import "../../../mocks/providers/provider_map_page.dart";
import "../../../mocks/services/mock_geo_location_service.dart";

void main() {
  late MockGeolocationService geoLocationService;
  late ProviderScope mapPage;

  late FakeFirebaseFirestore fakeFirestore;
  late FirestorePostGenerator postGenerator;
  late List<PostFirestore> nearbyPosts;
  late List<PostFirestore> userPosts;

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

    postGenerator = FirestorePostGenerator();

    nearbyPosts = postGenerator.generatePostsAtDifferentLocations(
      GeoPointGenerator.generatePositions(userPosition0, 10, 0),
    );
    await setPostsFirestore(nearbyPosts, fakeFirestore);
    final farPosts = postGenerator.generatePostsAtDifferentLocations(
      GeoPointGenerator.generatePositions(userPosition0, 0, 10),
    );
    await setPostsFirestore(farPosts, fakeFirestore);

    userPosts = postGenerator.createUserPosts(
      testingUserFirestoreId,
      userPosition1,
      10,
    );
    await setPostsFirestore(userPosts, fakeFirestore);
  });

  Future<ProviderContainer> beginTest(WidgetTester tester) async {
    await tester.pumpWidget(mapPage);
    await tester.pumpAndSettle();

    final element = tester.element(find.byType(MapScreen));
    return ProviderScope.containerOf(element);
  }

  void expectPinsAndPostsMatch(
    List<MapPinDetails> pins,
    List<PostFirestore> posts,
  ) {
    // Compare the ids
    final pinsId = pins.map((pin) => pin.id.value);
    final postIds = posts.map((post) => post.id.value);
    expect(pinsId, unorderedEquals(postIds));

    // Compare the positions
    final pinsPosition = pins.map((pin) {
      final pos = pin.position;
      return GeoPoint(pos.latitude, pos.longitude);
    });
    final postPositions = posts.map((post) => post.location.geoPoint);
    expect(pinsPosition, unorderedEquals(postPositions));
  }

  group("Option selection", () {
    testWidgets("Correct default option", (tester) async {
      final container = await beginTest(tester);

      final currentOption = container.read(
        mapSelectionOptionsViewModelProvider,
      );
      expect(
        currentOption,
        equals(MapSelectionOptionsViewModel.defaultMapOption),
      );
    });

    testWidgets("Nearby posts work", (tester) async {
      final container = await beginTest(tester);

      final option = find.byKey(
        MapSelectionOptionChips.optionChipKeys[MapSelectionOptions.nearby]!,
      );
      expect(option, findsOneWidget);
      await tester.tap(option);
      await tester.pumpAndSettle();

      final currentOption = container.read(
        mapSelectionOptionsViewModelProvider,
      );
      expect(currentOption, equals(MapSelectionOptions.nearby));

      final pins = await container.read(mapPinViewModelProvider.future);
      expectPinsAndPostsMatch(pins, nearbyPosts);
    });

    testWidgets("User posts work", (tester) async {
      final container = await beginTest(tester);

      final option = find.byKey(
        MapSelectionOptionChips.optionChipKeys[MapSelectionOptions.myPosts]!,
      );
      expect(option, findsOneWidget);
      await tester.tap(option);
      await tester.pumpAndSettle();

      final currentOption = container.read(
        mapSelectionOptionsViewModelProvider,
      );
      expect(currentOption, equals(MapSelectionOptions.myPosts));

      final pins = await container.read(mapPinViewModelProvider.future);
      expectPinsAndPostsMatch(pins, userPosts);
    });
  });
}
