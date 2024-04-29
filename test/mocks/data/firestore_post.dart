import "dart:math";

import "package:cloud_firestore/cloud_firestore.dart";
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
    return createPostAt(
      PostDataGenerator.generatePostData(1).first,
      location,
    );
  }

  List<PostFirestore> generatePostsAt(GeoPoint location, int n) {
    final List<PostData> data = PostDataGenerator.generatePostData(n);
    final List<PostFirestore> posts = [];
    for (int i = 0; i < n; i++) {
      posts.add(createPostAt(data[i], location));
    }
    return posts;
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
        publicationTime: Timestamp.fromMicrosecondsSinceEpoch(1000000),
        voteScore: Random().nextInt(100),
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
    return (await addPosts(firestore, location, n)).map((e) => e.data).toList();
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
