import "package:cloud_firestore/cloud_firestore.dart";

const userPosition0 = GeoPoint(0, 0);

const userPosition1 = GeoPoint(40, 20);

const nearbyPostPosition = GeoPoint(40.0001, 20.0001); // 14m away
const farAwayPostPosition = GeoPoint(40.001, 20.001); // about 140m away
const postOnEdgeInsidePosition = GeoPoint(
  39.999999993872564,
  20.001188563379976 - 1e-5,
); // just below 100m away
const postOnEdgeOutsidePosition = GeoPoint(
  39.999999993872564,
  20.001188563379976 + 1e-5,
); // just above 100m away

const userPosition2 = GeoPoint(10, 10);
const userPosition3 = GeoPoint(50, 100);

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
