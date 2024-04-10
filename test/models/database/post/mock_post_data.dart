import "package:cloud_firestore/cloud_firestore.dart";
import "package:geoflutterfire2/geoflutterfire2.dart";
import "package:proxima/models/database/post/post_data.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/post/post_location_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";

/// Helper class to create mock post data to be used in tests
class MockPostFirestore {
  static PostFirestore createPostAt(
    PostData data,
    GeoPoint location, {
    id = "post_id",
  }) {
    final point = GeoFirePoint(location.latitude, location.longitude);

    return PostFirestore(
      id: PostIdFirestore(value: id),
      location: PostLocationFirestore(
        geoPoint: location,
        geohash: point.hash,
      ),
      data: data,
    );
  }

  static List<PostData> generatePostData(int count) {
    return List.generate(count, (i) {
      return PostData(
        description: "description_$i",
        title: "title_$i",
        ownerId: UserIdFirestore(value: "owner_id_$i"),
        publicationTime: Timestamp.fromMillisecondsSinceEpoch(1000 * i),
        voteScore: i,
      );
    });
  }
}
