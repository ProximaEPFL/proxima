import "dart:math";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:collection/collection.dart";
import "package:geoflutterfire_plus/geoflutterfire_plus.dart";
import "package:proxima/models/database/post/post_data.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/post/post_location_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";

import "post_data.dart";

/// Helper class to create mock post data to be used in tests
class FirestorePostGenerator {
  int _postId = 0;

  /// Create a [PostFirestore] with given data
  PostFirestore createPostAt(
    PostData data,
    GeoPoint location, {
    String? id,
  }) {
    final point = GeoFirePoint(location);

    id ??= (_postId++).toString();

    return PostFirestore(
      id: PostIdFirestore(value: id),
      location: PostLocationFirestore(
        geoPoint: location,
        geohash: point.geohash,
      ),
      data: data,
    );
  }

  /// Generate a [PostFirestore] at position [location], generating the post data
  PostFirestore generatePostAt(GeoPoint location) {
    return generatePostsAt(location, 1).first;
  }

  /// Generate [n] [PostFirestore] at position [location]
  List<PostFirestore> generatePostsAt(GeoPoint location, int n) {
    return generatePostsAtDifferentLocations(List.filled(n, location));
  }

  /// Generate [locations.length] [PostFirestore], at the positions given by [locations]
  List<PostFirestore> generatePostsAtDifferentLocations(
    List<GeoPoint> locations,
  ) {
    final List<PostData> data = PostDataGenerator.generatePostData(
      locations.length,
    );
    final posts = locations.mapIndexed(
      (i, location) => createPostAt(data[i], location),
    );
    return posts.toList();
  }

  /// Create a [PostFirestore] with random data
  PostFirestore createUserPost(
    UserIdFirestore userId,
    GeoPoint location,
  ) {
    final point = GeoPoint(location.latitude, location.longitude);

    _postId += 1;

    return PostFirestore(
      id: PostIdFirestore(
        value: _postId.toString(),
      ),
      location: PostLocationFirestore(
        geoPoint: location,
        geohash: point.toString(),
      ),
      data: PostData(
        ownerId: userId,
        title: "title",
        description: "desciption",
        publicationTime:
            Timestamp.fromMicrosecondsSinceEpoch(Random().nextInt(100000000)),
        voteScore: Random().nextInt(100),
        commentCount: Random().nextInt(100),
      ),
    );
  }

  /// Add [n] posts at position [location] and return their data and the [PostFirestore] objects
  Future<List<PostFirestore>> addPosts(
    FirebaseFirestore firestore,
    GeoPoint location,
    int n,
  ) async {
    final List<PostFirestore> fakePosts = generatePostsAt(location, n);
    await setPostsFirestore(fakePosts, firestore);
    return fakePosts;
  }

  /// Add [n] posts at position [location] and return their data
  Future<List<PostData>> addPostsReturnDataOnly(
    FirebaseFirestore firestore,
    GeoPoint location,
    int n,
  ) async {
    final posts = await addPosts(firestore, location, n);
    return posts.map((post) => post.data).toList();
  }
}

/// Helper function to set a post in the firestore db
Future<void> setPostFirestore(
  PostFirestore post,
  FirebaseFirestore firestore,
) async {
  final Map<String, dynamic> locationData = {
    PostLocationFirestore.geoPointField: post.location.geoPoint,
    PostLocationFirestore.geohashField: post.location.geohash,
  };

  await firestore
      .collection(PostFirestore.collectionName)
      .doc(post.id.value)
      .set({
    PostFirestore.locationField: locationData,
    ...post.data.toDbData(),
  });
}

Future<void> setPostsFirestore(
  List<PostFirestore> posts,
  FirebaseFirestore firestore,
) async {
  for (final post in posts) {
    await setPostFirestore(post, firestore);
  }
}
