import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:geolocator/geolocator.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:mockito/mockito.dart";
import "package:proxima/services/database/firestore_service.dart";
import "package:proxima/services/database/user_repository_service.dart";
import "package:proxima/services/sensors/geolocation_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";
import "package:proxima/viewmodels/map/map_pin_view_model.dart";
import "package:proxima/views/pages/home/content/map/components/map_pin_pop_up.dart";
import "package:proxima/views/pages/home/content/map/map_screen.dart";
import "package:proxima/views/pages/post/post_page.dart";

import "../../mocks/data/firestore_post.dart";
import "../../mocks/data/firestore_user.dart";
import "../../mocks/data/geopoint.dart";
import "../../mocks/providers/provider_map_page.dart";
import "../../mocks/services/mock_geolocator_platform.dart";
import "../../mocks/services/mock_user_repository_service.dart";

void main() {
  group("Map Pin View Model integration testing", () {
    late FakeFirebaseFirestore fakeFireStore;
    late MockGeolocatorPlatform mockGeolocator;
    late GeolocationService geolocationService;
    late ProviderContainer container;
    late FirestorePostGenerator postGenerator;
    late MockUserRepositoryService userRepositoryService;
    late ProviderScope mapWidgetWithPins;

    setUp(() async {
      fakeFireStore = FakeFirebaseFirestore();
      mockGeolocator = MockGeolocatorPlatform();
      geolocationService = GeolocationService(geoLocator: mockGeolocator);
      postGenerator = FirestorePostGenerator();
      userRepositoryService = MockUserRepositoryService();
      mapWidgetWithPins = newMapPageWithPinsNoOverride(
        geolocationService,
        fakeFireStore,
        testingUserFirestoreId,
        userRepositoryService,
      );

      when(mockGeolocator.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(mockGeolocator.checkPermission())
          .thenAnswer((_) async => LocationPermission.always);

      when(userRepositoryService.getUser(testingUserFirestoreId))
          .thenAnswer((_) async => testingUserFirestore);

      container = ProviderContainer(
        overrides: [
          geolocationServiceProvider.overrideWithValue(geolocationService),
          loggedInUserIdProvider.overrideWithValue(testingUserFirestoreId),
          firestoreProvider.overrideWithValue(fakeFireStore),
          userRepositoryServiceProvider
              .overrideWithValue(userRepositoryService),
        ],
      );
    });

    group("Standing still tests", () {
      setUp(
        () {
          final position = getSimplePosition(
            userPosition0.latitude,
            userPosition0.longitude,
          );
          when(
            mockGeolocator.getCurrentPosition(
              locationSettings: geolocationService.locationSettings,
            ),
          ).thenAnswer(
            (_) async => position,
          );

          when(
            mockGeolocator.getPositionStream(
              locationSettings: geolocationService.locationSettings,
            ),
          ).thenAnswer(
            (_) => Stream.fromIterable([
              position,
            ]),
          );
        },
      );

      test("No posts available returns empty pin list", () async {
        final pinList = await container.read(mapPinViewModelProvider.future);

        expect(pinList, isEmpty);
      });

      test(
          "Posts available in range and out of range, returns only pins associated to in range posts",
          () async {
        // Generate 10 random positions around the user but in range to be able to see them
        // and 15 random positions out of range.
        const postsInRange = 10;
        const postsOutOfRange = 15;

        final geoPointsPositions = GeoPointGenerator.generatePositions(
          userPosition0,
          postsInRange,
          postsOutOfRange,
        );

        final generatedPosts =
            postGenerator.generatePostsAtDifferentLocations(geoPointsPositions);

        await setPostsFirestore(generatedPosts, fakeFireStore);

        final pinList = await container.read(mapPinViewModelProvider.future);

        // We need to decompose the pins list into tuple because every [callbackFunction] created are different
        // so we cannot test equality on them as expect(pinList, unorderedEquals(expectedPins));
        // if pinList and expectedPins are of type List<MapPinDetails>.

        final pinListTuple = pinList
            .map(
              (pin) => (pin.id, pin.position),
            )
            .toList();

        final expectedPinsTuple = generatedPosts
            .take(postsInRange)
            .map(
              (post) => (
                MarkerId(post.id.value),
                LatLng(
                  post.location.geoPoint.latitude,
                  post.location.geoPoint.longitude,
                ),
              ),
            )
            .toList();

        expect(pinListTuple, unorderedEquals(expectedPinsTuple));
      });

      testWidgets("callback function is created as expected", (tester) async {
        // Generate 10 random positions around the user but in range to be able to see them
        // and 15 random positions out of range.
        const postsInRange = 10;
        const postsOutOfRange = 15;

        final geoPointsPositions = GeoPointGenerator.generatePositions(
          userPosition0,
          postsInRange,
          postsOutOfRange,
        );

        final generatedPosts =
            postGenerator.generatePostsAtDifferentLocations(geoPointsPositions);

        await setPostsFirestore(generatedPosts, fakeFireStore);

        await tester.pumpWidget(mapWidgetWithPins);
        await tester.pumpAndSettle();

        final element = tester.element(find.byType(MapScreen));

        final container = ProviderScope.containerOf(element);

        final mapPinNotifier = container.read(mapPinViewModelProvider.notifier);

        mapPinNotifier.setContext(element);

        await mapPinNotifier.refresh();
        await tester.pumpAndSettle();

        final pinList = await container.read(mapPinViewModelProvider.future);
        await tester.pumpAndSettle();

        expect(pinList, isNotEmpty);

        //check that the callback function of the pin shows a dialog
        final pin = pinList.first;
        pin.callbackFunction();

        await tester.pumpAndSettle();
        expect(find.byType(MapPinPopUp), findsOneWidget);

        //click on the button in the popup
        final arrowButton = find.byKey(MapPinPopUp.arrowButtonKey);
        expect(arrowButton, findsOneWidget);

        await tester.tap(arrowButton);

        await tester.pumpAndSettle();
        //check that we have a post overview page
        expect(find.byType(PostPage), findsOneWidget);
      });
    });

    group("Moving position test", () {
      test(
        "Pin list adapt with moving position",
        () async {
          // For this test we are going to create 2 posts positions.
          // The goal is going to move the user and check if the expected pins are returned.

          final postPositions =
              GeoPointGenerator.generatePositions(userPosition0, 1, 1);

          postPositions
              .map((position) => postGenerator.generatePostAt(position));

          final generatedPosts =
              postGenerator.generatePostsAtDifferentLocations(postPositions);

          await setPostsFirestore(generatedPosts, fakeFireStore);

          // Set the initial position
          when(
            mockGeolocator.getCurrentPosition(
              locationSettings: geolocationService.locationSettings,
            ),
          ).thenAnswer(
            (_) async => getSimplePosition(
              postPositions[0].latitude,
              postPositions[0].longitude,
            ),
          );

          when(
            mockGeolocator.getPositionStream(
              locationSettings: geolocationService.locationSettings,
            ),
          ).thenAnswer(
            //We need to introduce delay in this test
            //because the notifier gets disposed by the new position
            //before it could emit it's value if not.
            (_) => Stream.periodic(
              const Duration(
                seconds: 1,
              ), // Adjust the duration to the desired delay
              (index) => index,
            ).take(postPositions.length).map(
              (index) {
                final geoPoint = postPositions[index];
                return getSimplePosition(geoPoint.latitude, geoPoint.longitude);
              },
            ),
          );

          for (int i = 0; i < 2; i++) {
            // Change the current position for consistency
            when(
              mockGeolocator.getCurrentPosition(
                locationSettings: geolocationService.locationSettings,
              ),
            ).thenAnswer(
              (_) async => getSimplePosition(
                postPositions[i].latitude,
                postPositions[i].longitude,
              ),
            );

            // Check that we only have a single pin
            final pinList =
                await container.read(mapPinViewModelProvider.future);

            expect(pinList, hasLength(1));

            // Check that the pin is the pin associated to the post at [postPositions[i]]
            // We need to decompose the pins because every [callbackFunction] created are different
            // so we cannot test equality on MapPinDetails directly
            expect(
              pinList[0].id,
              MarkerId(generatedPosts[i].id.value),
            );
            expect(
              pinList[0].position.latitude,
              generatedPosts[i].location.geoPoint.latitude,
            );
            expect(
              pinList[0].position.longitude,
              generatedPosts[i].location.geoPoint.longitude,
            );

            //this ensure that the new position is emitted by the stream before we start a new iteration
            await Future.delayed(
              const Duration(
                seconds: 1,
              ), // Adjust the duration to the desired delay
            );
          }
        },
      );
    });
  });
}
