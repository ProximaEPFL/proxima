import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:mockito/mockito.dart";
import "package:proxima/viewmodels/map/map_view_model.dart";

import "../../mocks/services/mock_geo_location_service.dart";
import "../../mocks/services/mock_google_map_controller.dart";

void main() {
  late MockGoogleMapController mockMapController;
  late MockGeoLocationService mockGeoLocationService;
  late MapViewModel mapViewModel;

  const GeoPoint initPosition = GeoPoint(1, 1);
  const GeoPoint finalPosition = GeoPoint(2, 2);

  setUp(() {
    mockMapController = MockGoogleMapController();
    mockGeoLocationService = MockGeoLocationService();
    mapViewModel = MapViewModel();

    mapViewModel.onMapCreated(mockMapController);

    when(mockGeoLocationService.getCurrentPosition())
        .thenAnswer((_) async => initPosition);
  });

  group("Camera", () {
    test("Camera follows user's live location by default", () {
      // Check if the map controller is created
      expect(mapViewModel.mapController.isCompleted, true);

      // Check if the camera is following the user's live location
      when(mockGeoLocationService.getCurrentPosition())
          .thenAnswer((_) async => finalPosition);

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
