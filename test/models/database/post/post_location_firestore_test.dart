import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/database/post/post_location_firestore.dart";

import "../../../mocks/data/mock_position.dart";

void main() {
  group("Post Location Firestore testing", () {
    test("hash overrides correctly", () {
      const geoPoint = userPosition1;
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
        PostLocationFirestore.geoPointField: userPosition1,
      };

      expect(
        () => PostLocationFirestore.fromDbData(data),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
