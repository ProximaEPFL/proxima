import "package:cloud_firestore/cloud_firestore.dart";
import "package:geoflutterfire2/geoflutterfire2.dart";
import "package:proxima/models/database/post_repository.dart";

class MockFirestorePost {
  PostFirestore createPostAt(
    PostFirestoreData data,
    GeoPoint location, {
    id = "post_id",
  }) {
    final point = GeoFirePoint(location.latitude, location.longitude);

    return PostFirestore(
      id: id,
      location: PostLocationFirestore(
        geoPoint: location,
        geohash: point.hash,
      ),
      data: data,
    );
  }

  List<PostFirestoreData> generatePostData(int count) {
    return List.generate(count, (i) {
      return PostFirestoreData(
        description: "description_$i",
        title: "title_$i",
        ownerId: "owner_id_$i",
        publicationTime: Timestamp.fromMillisecondsSinceEpoch(1000 * i),
        voteScore: i,
      );
    });
  }
}
