import "dart:async";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:geolocator/geolocator.dart";
import "package:mockito/mockito.dart";
import "package:proxima/services/geolocation_service.dart";

import "../mocks/data/geopoint.dart";
import "../mocks/services/mock_geolocator_platform.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("GeoLocationService", () {
    late GeoLocationService geoLocationService;
    late MockGeolocatorPlatform mockGeolocator;

    setUp(() {
      mockGeolocator = MockGeolocatorPlatform();
      geoLocationService = GeoLocationService(geoLocator: mockGeolocator);
    });

    test("getCurrentPosition returns GeoPoint", () async {
      const latitude = 37.4219983;
      const longitude = -122.084;
      const expectedGeoPoint = GeoPoint(latitude, longitude);

      when(mockGeolocator.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(mockGeolocator.checkPermission())
          .thenAnswer((_) async => LocationPermission.always);
      when(
        mockGeolocator.getCurrentPosition(
          locationSettings: geoLocationService.locationSettings,
        ),
      ).thenAnswer(
        (_) async => getSimplePosition(latitude, longitude),
      );

      final result = await geoLocationService.getCurrentPosition();

      expect(result, equals(expectedGeoPoint));
    });

    test(
        "getCurrentPosition throws exception when location services are disabled",
        () async {
      when(mockGeolocator.isLocationServiceEnabled())
          .thenAnswer((_) async => false);

      expect(
        () => geoLocationService.getCurrentPosition(),
        throwsA(isA<Exception>()),
      );
    });

    test(
        "getCurrentPosition throws exception when location permissions are denied",
        () async {
      when(mockGeolocator.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(mockGeolocator.checkPermission())
          .thenAnswer((_) async => LocationPermission.denied);
      when(mockGeolocator.requestPermission())
          .thenAnswer((_) async => LocationPermission.denied);

      expect(
        () => geoLocationService.getCurrentPosition(),
        throwsA(isA<Exception>()),
      );
    });

    test(
        "getCurrentPosition throws exception when location permissions are permanently denied",
        () async {
      when(mockGeolocator.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(mockGeolocator.checkPermission())
          .thenAnswer((_) async => LocationPermission.deniedForever);
      when(mockGeolocator.requestPermission())
          .thenAnswer((_) async => LocationPermission.deniedForever);
      when(mockGeolocator.checkPermission())
          .thenAnswer((_) async => LocationPermission.deniedForever);

      expect(
        () => geoLocationService.getCurrentPosition(),
        throwsA(isA<Exception>()),
      );
    });

    test(
        "getCurrentPosition requests permission when permission is denied and return correct result when permission is granted",
        () async {
      const expectedGeoPoint = userPosition1;

      when(mockGeolocator.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(mockGeolocator.checkPermission())
          .thenAnswer((_) async => LocationPermission.denied);
      when(mockGeolocator.requestPermission())
          .thenAnswer((_) async => LocationPermission.always);
      when(
        mockGeolocator.getCurrentPosition(
          locationSettings: geoLocationService.locationSettings,
        ),
      ).thenAnswer(
        (_) async => getSimplePosition(
          expectedGeoPoint.latitude,
          expectedGeoPoint.longitude,
        ),
      );

      final actualGeoPoint = await geoLocationService.getCurrentPosition();

      verify(mockGeolocator.requestPermission()).called(1);
      expect(actualGeoPoint, equals(expectedGeoPoint));
    });

    test("determinePosition returns a stream", () async {
      const latitude = 37.4219983;
      const longitude = -122.084;

      when(mockGeolocator.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(mockGeolocator.checkPermission())
          .thenAnswer((_) async => LocationPermission.always);
      when(
        mockGeolocator.getCurrentPosition(
          locationSettings: geoLocationService.locationSettings,
        ),
      ).thenAnswer(
        (_) async => getSimplePosition(latitude, longitude),
      );
      when(
        mockGeolocator.getPositionStream(
          locationSettings: geoLocationService.locationSettings,
        ),
      ).thenAnswer(
        (_) => Stream.fromIterable([
          getSimplePosition(latitude, longitude),
          getSimplePosition(latitude + 1, longitude + 1),
        ]),
      );

      final stream = await geoLocationService.getPositionStream();

      final actualGeoPoint1 = await stream.first;

      //read the second value
      final actualGeoPoint2 = await stream.elementAt(1);

      expect(actualGeoPoint1, equals(const GeoPoint(latitude, longitude)));
      expect(
        actualGeoPoint2,
        equals(const GeoPoint(latitude + 1, longitude + 1)),
      );
    });
  });
}
