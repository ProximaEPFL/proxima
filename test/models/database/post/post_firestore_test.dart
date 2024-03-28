import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/database/post/post_data.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/post/post_location_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";

void main() {
  group("Post Firestore testing", () {
    test("hash overrides correctly", () {
      const geoPoint = GeoPoint(40, 20);
      const geoHash = "azdz";

      const location = PostLocationFirestore(
        geoPoint: geoPoint,
        geohash: geoHash,
      );

      final data = PostData(
        ownerId: const UserIdFirestore(value: "owner_id"),
        title: "post_tiltle",
        description: "description",
        publicationTime: Timestamp.fromMillisecondsSinceEpoch(4564654),
        voteScore: 12,
      );

      final post = PostFirestore(
        id: const PostIdFirestore(value: "post_id"),
        location: location,
        data: data,
      );

      final expectedHash = Object.hash(post.id, post.location, post.data);

      final actualHash = post.hashCode;

      expect(actualHash, expectedHash);
    });
  });
}
