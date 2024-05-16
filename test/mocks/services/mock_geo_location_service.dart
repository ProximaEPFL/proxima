import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mockito/mockito.dart";
import "package:proxima/services/sensors/geolocation_service.dart";

import "../data/geopoint.dart";

class MockGeolocationService extends Mock implements GeolocationService {
  @override
  Future<GeoPoint> getCurrentPosition() {
    return super.noSuchMethod(
      Invocation.method(#getCurrentPosition, []),
      returnValue: Future.value(userPosition0),
    );
  }

  @override
  Stream<GeoPoint> getPositionStream() {
    return super.noSuchMethod(
      Invocation.method(#requestPermission, []),
      returnValue: Stream.value(userPosition0),
    );
  }
}
