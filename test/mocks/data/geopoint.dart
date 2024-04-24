import "package:cloud_firestore/cloud_firestore.dart";

const userPosition0 = GeoPoint(0, 0);
const userPosition1 = GeoPoint(40, 20);
const userPosition2 = GeoPoint(10, 10);
const userPosition3 = GeoPoint(50, 100);

class GeoPointGenerator {
  GeoPointGenerator._();

  /// Method to create a nearby position
  static GeoPoint createNearbyPosition(GeoPoint userPosition) {
    return GeoPoint(
      userPosition.latitude + 0.0001,
      userPosition.longitude + 0.0001,
    );
  }

  /// Method to create a far away position
  static GeoPoint createFarAwayPosition(
    GeoPoint userPosition,
    double range,
  ) {
    return GeoPoint(
      userPosition.latitude + range * 2,
      userPosition.longitude + range * 2,
    );
  }

  /// Conversion factor from kilometers to degrees (latitude).
  static double kmToDegreesLat(double km) => km / 111.0;

  /// Method to create a position on the edge of the range but inside
  static GeoPoint createOnEdgeInsidePosition(
    GeoPoint userPosition,
    double range,
  ) {
    // Convert range to degrees
    double rangeInDegreesLatitude = kmToDegreesLat(range);

    // Smaller reduction to ensure it's inside for very small ranges like 100 meters
    double reductionOffset = 0.0001; // approx 11 meters

    return GeoPoint(
      userPosition.latitude + rangeInDegreesLatitude - reductionOffset,
      userPosition.longitude,
    );
  }

  /// Method to create a position on the edge of the range but outside
  static GeoPoint createOnEdgeOutsidePosition(
    GeoPoint userPosition,
    double range,
  ) {
    // Conversion of range from kilometers to degrees
    double rangeInDegreesLatitude = kmToDegreesLat(range);

    // Slightly increase the range to ensure the position is outside
    double additionalOffset = 0.0001; // approx 11 meters

    return GeoPoint(
      userPosition.latitude + rangeInDegreesLatitude + additionalOffset,
      userPosition.longitude,
    );
  }

  /// Generate a list of [GeoPoint] positions, [inRange] of which are in range
  /// (i.e. less than 100 m away) of the [userPosition], and [outRange] of which
  /// are out of range of this position
  static List<GeoPoint> generatePositions(
    GeoPoint userPosition,
    int inRange,
    int outRange,
  ) {
    assert(inRange >= 0 && outRange >= 0);

    const maxDiagonalDistanceInRange = 0.0005;
    const minDiagonalOutRange = 0.001;
    double distanceBetweenpositions =
        maxDiagonalDistanceInRange / (inRange + 1);

    double userLatitude = userPosition.latitude;
    double userLongitude = userPosition.longitude;

    final positionInRange = List.generate(inRange, (i) {
      double dDirection = distanceBetweenpositions * i;
      return GeoPoint(
        userLatitude + dDirection,
        userLongitude + dDirection,
      );
    });

    // Generate position positions that are not in the range.
    final positionsNotInRange = List.generate(outRange, (i) {
      double dDirection = minDiagonalOutRange + distanceBetweenpositions * i;
      return GeoPoint(
        userLatitude + dDirection,
        userLongitude + dDirection,
      );
    });

    return [...positionInRange, ...positionsNotInRange];
  }
}
