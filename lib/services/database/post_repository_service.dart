import "package:cloud_firestore/cloud_firestore.dart";
import "package:geoflutterfire2/geoflutterfire2.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_data.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/services/database/firestore_service.dart";

class PostRepositoryService {
  final GeoFlutterFire _geoFire;
  final CollectionReference _collectionRef;

  PostRepositoryService({
    required FirebaseFirestore firestore,
  })  : _collectionRef = firestore.collection(PostFirestore.collectionName),
        _geoFire = GeoFlutterFire();

  /// Adds a post at the current location of the user
  Future<void> addPost(PostData postData, GeoFirePoint position) async {
    // The `point.data` returns a Map<String, dynamic> consistent with the
    // class [PostLocationFirestore]. This is because the field name values
    // are hardcoded in the [GeoFlutterFire] library

    await _collectionRef.add({
      PostFirestore.locationField: position.data,
      ...postData.toDbData(),
    });
  }

  /// Deletes a post by its id
  Future<void> deletePost(PostIdFirestore postId) async {
    await _collectionRef.doc(postId.value).delete();
  }

  /// Get a post by its id
  Future<PostFirestore> getPost(PostIdFirestore postId) async {
    final docSnap = await _collectionRef.doc(postId.value).get();

    return PostFirestore.fromDb(docSnap);
  }

  /// Get the posts near a given point
  /// The radius is defined by [kmPostRadius]
  Future<List<PostFirestore>> getNearPosts(
    GeoFirePoint point,
    double radius,
  ) async {
    final posts = await _geoFire
        .collection(collectionRef: _collectionRef)
        .withinAsSingleStreamSubscription(
          center: point,
          radius: radius,
          field: PostFirestore.locationField,
          strictMode: false,
        )
        .first;

    return posts.map((docSnap) => PostFirestore.fromDb(docSnap)).where((post) {
      // We need to filter the posts because the query is not exact
      final postPoint = post.location.geoPoint;
      return point.distance(
            lat: postPoint.latitude,
            lng: postPoint.longitude,
          ) <=
          radius;
    }).toList();
  }
}

final postRepositoryProvider = Provider<PostRepositoryService>(
  (ref) => PostRepositoryService(
    firestore: ref.watch(firestoreProvider),
  ),
);
