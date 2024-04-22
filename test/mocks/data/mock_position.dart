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
GeoPoint createFarAwayPostPosition(GeoPoint userPosition) {
  return GeoPoint(
    userPosition.latitude + 0.001,
    userPosition.longitude + 0.001,
  );
}

/// Method to create a post on the edge of the range but inside
GeoPoint createPostOnEdgeInsidePosition(GeoPoint userPosition) {
  return GeoPoint(
    userPosition.latitude - 1e-8,
    userPosition.longitude + 1e-5,
  );
}

/// Method to create a post on the edge of the range but outside
GeoPoint createPostOnEdgeOutsidePosition(GeoPoint userPosition) {
  return GeoPoint(
    userPosition.latitude + 1e-8,
    userPosition.longitude + 1e-5,
  );
}

/// Generate a list of [GeoPoint] positions, some in range (max 7) and some out of range
List<GeoPoint> generatePositions(
  GeoPoint userPosition,
  int inRange,
  int outRange,
) {
  double userLatitude = userPosition.latitude;
  double userLongitude = userPosition.longitude;

  final postInRange = List.generate(inRange, (i) {
    return GeoPoint(
      userLatitude + 0.0001 + (i % 7) * 0.0001,
      userLongitude + 0.0001 + (i % 7) * 0.0001,
    );
  });

  // Generate post positions that are not in the range.
  // The distance between [userPosition = GeoPoint(0, 0)] and a GetPoint at
  // latitude 0.0006 and longitude 0.0006 is about 0.11 km.
  final postsNotInRange = List.generate(outRange, (i) {
    i = i + 7; // makes it out of range
    return GeoPoint(
      userLatitude + 0.0001 + i * 0.0001,
      userLongitude + 0.0001 + i * 0.0001,
    );
  });

  return [...postInRange, ...postsNotInRange];
}
