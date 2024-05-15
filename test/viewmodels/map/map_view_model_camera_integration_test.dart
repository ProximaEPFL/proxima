import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:geolocator/geolocator.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:mockito/mockito.dart";
import "package:proxima/services/sensors/geolocation_service.dart";
import "package:proxima/viewmodels/map/map_view_model.dart";

import "../../mocks/services/mock_geo_location_service.dart";
import "../../mocks/services/mock_geolocator_platform.dart";
import "../../mocks/services/mock_google_map_controller.dart";

void main() {
  late MockGoogleMapController mockMapController;
  late MockGeolocatorPlatform mockGeolocator;
  late GeolocationService geolocationService;
  late MapViewModel mapViewModel;
  late ProviderContainer container;

  const GeoPoint initPosition = GeoPoint(1, 1);
  const GeoPoint finalPosition = GeoPoint(2, 2);

  setUp(() {
    mockMapController = MockGoogleMapController();
    mockGeolocator = MockGeolocatorPlatform();
    geolocationService = GeolocationService(geoLocator: mockGeolocator);
    mapViewModel = MapViewModel();

    mapViewModel.onMapCreated(mockMapController);

    when(mockGeolocator.isLocationServiceEnabled())
        .thenAnswer((_) async => true);
    when(mockGeolocator.checkPermission())
        .thenAnswer((_) async => LocationPermission.always);

    container = ProviderContainer(
      overrides: [
        geolocationServiceProvider.overrideWithValue(geolocationService),
      ],
    );
  });

  group("Camera", () {
    test("Camera follows user's live location by default", () {
      // Check if the map controller is created
      expect(mapViewModel.mapController.isCompleted, true);

      // Check if the camera is following the user's live location
      // Set the initial position
      when(
        mockGeolocator.getCurrentPosition(
          locationSettings: geoLocationService.locationSettings,
        ),
      ).thenAnswer(
        (_) async => getSimplePosition(
          postPositions[0].latitude,
          postPositions[0].longitude,
        ),
      );

      // Set the moving position
      when(
        mockGeolocator.getPositionStream(
          locationSettings: geoLocationService.locationSettings,
        ),
      ).thenAnswer(
        (_) => Stream.fromIterable(
          postPositions.map(
            (geoPoint) =>
                getSimplePosition(geoPoint.latitude, geoPoint.longitude),
          ),
        ),
      );

      // Check if the map controller calls animateCamera
      final newCameraPosition = CameraPosition(
        target: LatLng(finalPosition.latitude, finalPosition.longitude),
        zoom: 15,
      );
      verify(
        mockMapController.animateCamera(
          CameraUpdate.newCameraPosition(newCameraPosition),
        ),
      ).called(1);
    });

    test("Camera stops following after user interaction", () {});

    test("Camera follows user again after clicking FAB", () {});
  });
}
