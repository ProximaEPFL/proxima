import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/database/post/post_location_firestore.dart";

void main() {
  group("Post Location Firestore testing", () {
    test("hash overrides correctly", () {
      const geoPoint = GeoPoint(40, 20);
      const geoHash = "azdz";

      final expectedHash = Object.hash(geoPoint, geoHash);

      const location = PostLocationFirestore(
        geoPoint: geoPoint,
        geohash: "azdz",
      );

      final actualHash = location.hashCode;

      expect(actualHash, expectedHash);
    });

    test("fromDbData throw error when missing fields", () {
      final data = <String, dynamic>{
        PostLocationFirestore.geoPointField: const GeoPoint(40, 20),
      };

      expect(
        () => PostLocationFirestore.fromDbData(data),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
