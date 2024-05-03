import "package:geolocator/geolocator.dart";
import "package:mockito/mockito.dart";

/// Helper function to create a simple position object
Position getSimplePosition(double latitude, double longitude) {
  return Position(
    latitude: latitude,
    longitude: longitude,
    timestamp: DateTime.fromMillisecondsSinceEpoch(123123123),
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

  @override
  Stream<Position> getPositionStream({
    LocationSettings? locationSettings,
  }) {
    return super.noSuchMethod(
      Invocation.method(#getPositionStream, []),
      returnValue: Stream.fromIterable([getSimplePosition(0, 0)]),
    );
  }
}
