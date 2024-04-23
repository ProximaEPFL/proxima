import "package:cloud_firestore/cloud_firestore.dart";

const userPosition0 = GeoPoint(0, 0);
const userPosition1 = GeoPoint(40, 20);
const userPosition2 = GeoPoint(10, 10);
const userPosition3 = GeoPoint(50, 100);

/// Method to create a nearby post position
GeoPoint createNearbyPostPosition(GeoPoint userPosition) {
  return GeoPoint(
    userPosition.latitude + 0.0001,
    userPosition.longitude + 0.0001,
  );
}

/// Method to create a far away post position
GeoPoint createFarAwayPostPosition(GeoPoint userPosition, double range) {
  return GeoPoint(
    userPosition.latitude + range * 2,
    userPosition.longitude + range * 2,
  );
}

/// Conversion factor from kilometers to degrees (latitude).
double kmToDegreesLat(double km) => km / 111.0;

/// Method to create a post on the edge of the range but inside
GeoPoint createPostOnEdgeInsidePosition(GeoPoint userPosition, double range) {
// Convert range to degrees
  double rangeInDegreesLatitude = kmToDegreesLat(range);

// Smaller reduction to ensure it's inside for very small ranges like 100 meters
  double reductionOffset = 0.0001; // approx 11 meters

  return GeoPoint(
    userPosition.latitude + rangeInDegreesLatitude - reductionOffset,
    userPosition.longitude,
  );
}

/// Method to create a post on the edge of the range but outside
GeoPoint createPostOnEdgeOutsidePosition(GeoPoint userPosition, double range) {
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
List<GeoPoint> generatePositions(
  GeoPoint userPosition,
  int inRange,
  int outRange,
) {
  assert(inRange >= 0 && outRange >= 0);

  const maxDiagonalDistanceInRange = 0.0005;
  const minDiagonalOutRange = 0.001;
  double distanceBetweenPosts = maxDiagonalDistanceInRange / (inRange + 1);

  double userLatitude = userPosition.latitude;
  double userLongitude = userPosition.longitude;

  final postInRange = List.generate(inRange, (i) {
    double dDirection = distanceBetweenPosts * i;
    return GeoPoint(
      userLatitude + dDirection,
      userLongitude + dDirection,
    );
  });

  // Generate post positions that are not in the range.
  final postsNotInRange = List.generate(outRange, (i) {
    double dDirection = minDiagonalOutRange + distanceBetweenPosts * i;
    return GeoPoint(
      userLatitude + dDirection,
      userLongitude + dDirection,
    );
  });

  return [...postInRange, ...postsNotInRange];
}
