import "dart:math";

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

/// Conversion factor from kilometers to degrees (longitude) at a given latitude.
double kmToDegreesLng(double km, double latitude) {
  double radiusAtLat = cos(latitude * pi / 180) * 111.0;
  return km / radiusAtLat;
}

/// Method to create a post on the edge of the range but inside
GeoPoint createPostOnEdgeInsidePosition(GeoPoint userPosition, double range) {
// Convert range to degrees
  double rangeInDegreesLatitude = kmToDegreesLat(range);
  double rangeInDegreesLongitude = kmToDegreesLng(range, userPosition.latitude);

// Smaller reduction to ensure it's inside for very small ranges like 100 meters
  double reductionOffset = 0.001;

  return GeoPoint(
    userPosition.latitude + rangeInDegreesLatitude - reductionOffset,
    userPosition.longitude + rangeInDegreesLongitude - reductionOffset,
  );
}

/// Method to create a post on the edge of the range but outside
GeoPoint createPostOnEdgeOutsidePosition(GeoPoint userPosition, double range) {
// Conversion of range from kilometers to degrees
  double rangeInDegreesLatitude = kmToDegreesLat(range);

// Calculating degrees for longitude based on user's latitude
  double rangeInDegreesLongitude = kmToDegreesLng(range, userPosition.latitude);

// Slightly increase the range to ensure the position is outside
  double additionalOffset =
      0.0001; // Small offset to ensure it's outside the range

  return GeoPoint(
    userPosition.latitude + rangeInDegreesLatitude + additionalOffset,
    userPosition.longitude + rangeInDegreesLongitude + additionalOffset,
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
