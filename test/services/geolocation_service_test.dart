import "package:cloud_firestore/cloud_firestore.dart";
import "package:geolocator/geolocator.dart";
import "package:mockito/mockito.dart";
import "package:proxima/services/geolocation_service.dart";
import "package:test/test.dart";

/// Helper function to create a simple position object
Position getSimplePosition(double latitude, double longitude) {
  return Position(
    latitude: latitude,
    longitude: longitude,
    timestamp: DateTime.now(),
    accuracy: 0,
    altitude: 0,
    heading: 0,
    speed: 0,
    speedAccuracy: 0,
    altitudeAccuracy: 0,
    headingAccuracy: 0,
  );
}

/// We need to override the methods in order to mock them in the tests
class MockGeolocatorPlatform extends Mock implements GeolocatorPlatform {
  @override
  Future<bool> isLocationServiceEnabled() async {
    return super.noSuchMethod(
      Invocation.method(#isLocationServiceEnabled, []),
      returnValue: Future.value(true),
    );
  }

  @override
  Future<LocationPermission> checkPermission() async {
    return super.noSuchMethod(
      Invocation.method(#checkPermission, []),
      returnValue: Future.value(LocationPermission.always),
    );
  }

  @override
  Future<LocationPermission> requestPermission() async {
    return super.noSuchMethod(
      Invocation.method(#requestPermission, []),
      returnValue: Future.value(LocationPermission.always),
    );
  }

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    return super.noSuchMethod(
      Invocation.method(#getCurrentPosition, []),
      returnValue: Future.value(getSimplePosition(0, 0)),
    );
  }
}

void main() {
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
      const expectedGeoPoint = GeoPoint(46.222, 41.4219983);

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
            expectedGeoPoint.latitude, expectedGeoPoint.longitude),
      );

      final actualGeoPoint = await geoLocationService.getCurrentPosition();

      verify(mockGeolocator.requestPermission()).called(1);
      expect(actualGeoPoint, equals(expectedGeoPoint));
    });
  });
}
