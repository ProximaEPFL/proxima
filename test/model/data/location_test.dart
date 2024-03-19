import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/data/location.dart";

void main() {
  group("Location representation testing", () {
    test("Location correctly created when inbounds", () {
      final location = Location(longitude: -155.5, latitude: 85.8);

      expect(location.longitude, -155.5);
      expect(location.latitude, 85.8);
    });

    test("Location throws ArgumentError for out of bounds longitude", () {
      expect(
        () => Location(longitude: -200, latitude: 85.8),
        throwsArgumentError,
        reason: "Longitude is out of bounds",
      );
      expect(
        () => Location(longitude: 200, latitude: 85.8),
        throwsArgumentError,
        reason: "Longitude is out of bounds",
      );
    });

    test("Location throws ArgumentError for out of bounds latitude", () {
      expect(
        () => Location(longitude: -155.5, latitude: -100),
        throwsArgumentError,
        reason: "Latitude is out of bounds",
      );
      expect(
        () => Location(longitude: -155.5, latitude: 100),
        throwsArgumentError,
        reason: "Latitude is out of bounds",
      );
    });
  });
}
