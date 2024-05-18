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
    late List<PostFirestore> nearbyPosts;
    late List<PostFirestore> userPosts;

    late Map<MapSelectionOptions, List<PostFirestore>> expectedPostsForOption;

    setUp(() async {
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

      expectedPostsForOption = {
        MapSelectionOptions.nearby: nearbyPosts,
        MapSelectionOptions.myPosts: userPosts,
      };
    });

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

    Future<void> testOption(
      ProviderContainer container,
      MapSelectionOptions option,
    ) async {
      // Verify the option of the view-model is correct
      final currentOption = container.read(
        mapSelectionOptionsViewModelProvider,
      );
      expect(currentOption, equals(option));

      // Verify the pins are correct
      final expectedPosts = expectedPostsForOption[option] ?? List.empty();
      final pins = await container.read(mapPinViewModelProvider.future);
      expectPinsAndPostsMatch(pins, expectedPosts);
    }

    testWidgets("Post options work", (tester) async {
      final container = await beginTest(tester);

      // Verify the default option has a correct behaviour even before we click on any chip
      await testOption(
        container,
        MapSelectionOptionsViewModel.defaultMapOption,
      );

      // Run the tests twice, because the first time we click on a chip, we may
      // not refresh the posts (the first chip may be the default value)
      for (int i = 0; i < 2; ++i) {
        for (final option in MapSelectionOptions.values) {
          // Click on option chip
          final optionChip = find.byKey(
            MapSelectionOptionChips.optionChipKeys[option]!,
          );
          expect(optionChip, findsOneWidget);
          await tester.tap(optionChip);
          await tester.pumpAndSettle();

          // Verify the option
          await testOption(container, option);
        }
      }
    });
  });
}
