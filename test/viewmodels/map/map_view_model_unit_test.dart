import "package:flutter_test/flutter_test.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:mockito/mockito.dart";
import "package:proxima/models/ui/map_details.dart";
import "package:proxima/services/sensors/geolocation_service.dart";
import "package:proxima/viewmodels/map/map_view_model.dart";

import "../../mocks/data/geopoint.dart";
import "../../mocks/services/mock_geo_location_service.dart";
import "../../mocks/services/mock_google_map_controller.dart";

void main() {
  late MockGoogleMapController mockGoogleMapController;
  late MapViewModel mapViewModel;
  late ProviderContainer container;
  late MockGeolocationService mockGeolocationService;

  setUp(() {
    mockGoogleMapController = MockGoogleMapController();
    mockGeolocationService = MockGeolocationService();

    container = ProviderContainer(
      overrides: [
        geolocationServiceProvider.overrideWithValue(mockGeolocationService),
        mapViewModelProvider.overrideWith(() => MapViewModel()),
      ],
    );

    mapViewModel = container.read(mapViewModelProvider.notifier);
  });
  //test the redraw circle method
  test("Redraw circle", () {
    //new position for the circle
    const newLocation = LatLng(1, 1);

    //redraw the circle
    mapViewModel.redrawCircle(newLocation);

    //check if the circle is redrawn in the new location
    expect(mapViewModel.circles.elementAt(0).center, newLocation);
  });

  test("On map create", () async {
    //create a new instance of the map controller
    mapViewModel.onMapCreated(mockGoogleMapController);

    //check if the map controller is created
    expect(mapViewModel.mapController.isCompleted, true);
  });

  group("Camera", () {
    test("Camera follows user by default", () async {
      //create a new instance of the map controller
      mapViewModel.onMapCreated(mockGoogleMapController);
      when(mockGoogleMapController.animateCamera(any)).thenAnswer((_) async {});

      //new position for the camera
      const newLocation = LatLng(1, 1);

      //move the camera
      await mapViewModel.updateCamera(newLocation);

      //check if the map controller is moved to the new location
      verify(mockGoogleMapController.animateCamera(any)).called(1);
    });

    test("Camera does not follow user when disabled, follow again when enabled",
        () async {
      //create a new instance of the map controller
      mapViewModel.onMapCreated(mockGoogleMapController);
      when(mockGoogleMapController.animateCamera(any)).thenAnswer((_) async {});

      //disable the camera
      mapViewModel.disableFollowUser();

      //new position for the camera
      const newLocation = LatLng(1, 1);

      //move the camera
      await mapViewModel.updateCamera(newLocation);

      //check if the map controller is not moved to the new location
      verifyNever(mockGoogleMapController.animateCamera(any));

      // enable again
      mapViewModel.enableFollowUser();
      await mapViewModel.updateCamera(newLocation);
      verify(mockGoogleMapController.animateCamera(any)).called(1);
    });
  });

  test("Refresh updates state with new location", () async {
    // Mock position value
    const userPosition = userPosition1;

    when(mockGeolocationService.getCurrentPosition())
        .thenAnswer((_) async => userPosition);

    // Call the refresh method
    await mapViewModel.refresh();

    // Verify the state is updated with the new location
    final newState = container.read(mapViewModelProvider);
    expect(newState, isInstanceOf<AsyncData<MapDetails>>());
    expect(
      newState.value!.initialLocation,
      LatLng(userPosition.latitude, userPosition.longitude),
    );

    // Verify that the mockGeolocationService was called twice
    verify(mockGeolocationService.getCurrentPosition()).called(greaterThan(0));
  });
}
