import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mockito/mockito.dart";
import "package:proxima/services/geolocation_service.dart";

import "../data/geopoint.dart";

class MockGeoLocationService extends Mock implements GeoLocationService {
  @override
  Future<GeoPoint> getCurrentPosition() {
    return super.noSuchMethod(
      Invocation.method(#getCurrentPosition, []),
      returnValue: Future.value(userPosition0),
    );
  }
}
