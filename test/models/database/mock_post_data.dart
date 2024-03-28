import "package:cloud_firestore/cloud_firestore.dart";
import "package:geoflutterfire2/geoflutterfire2.dart";
import "package:proxima/models/database/post_repository.dart";
import "package:proxima/models/database/user_repository.dart";

class MockFirestorePost {
  PostFirestore createPostAt(
    PostDataFirestore data,
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

  List<PostDataFirestore> generatePostData(int count) {
    return List.generate(count, (i) {
      return PostDataFirestore(
        description: "description_$i",
        title: "title_$i",
        ownerId: UserIdFirestore(value: "owner_id_$i"),
        publicationTime: Timestamp.fromMillisecondsSinceEpoch(1000 * i),
        voteScore: i,
      );
    });
  }
}
