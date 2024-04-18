import "package:cloud_firestore/cloud_firestore.dart";
import "package:geoflutterfire_plus/geoflutterfire_plus.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_data.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/post/post_location_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/services/database/firestore_service.dart";

/// This repository service is responsible for managing the posts in the database
class PostRepositoryService {
  final CollectionReference _collectionRef;

  PostRepositoryService({
    required FirebaseFirestore firestore,
  }) : _collectionRef = firestore.collection(PostFirestore.collectionName);

  /// This method creates a new post that has for data [postData]
  /// and that is located at [position] and adds it to the database
  Future<PostIdFirestore> addPost(PostData postData, GeoPoint position) async {
    final geoFirePoint = GeoFirePoint(position);

    final reference = await _collectionRef.add({
      PostFirestore.locationField: _geoFirePointToDataDb(geoFirePoint),
      ...postData.toDbData(),
    });
    return PostIdFirestore(value: reference.id);
  }

  /// This method deletes the post with id [postId] from the database
  Future<void> deletePost(PostIdFirestore postId) async {
    await _collectionRef.doc(postId.value).delete();
  }

  /// This method returns the post with id [postId] from the database
  Future<PostFirestore> getPost(PostIdFirestore postId) async {
    final docSnap = await _collectionRef.doc(postId.value).get();

    return PostFirestore.fromDb(docSnap);
  }

  /// This method will retrieve all the posts that are within a radius of [radius]
  /// from the geo point [point] in the database
  /// And then those posts are returned
  Future<List<PostFirestore>> getNearPosts(
    GeoPoint point,
    double radius,
  ) async {
    final geoFirePoint = GeoFirePoint(point);

    // Function to get the GeoPoint from the data
    // This is needed because the GeoCollectionReference does not know how to
    // extract the GeoPoint from the data otherwise
    GeoPoint geopointFrom(data) => (data[PostFirestore.locationField]
            as Map<String, dynamic>)[PostLocationFirestore.geoPointField]
        as GeoPoint;

    final posts =
        await GeoCollectionReference(_collectionRef).fetchWithinWithDistance(
      center: geoFirePoint,
      radiusInKm: radius,
      field: PostFirestore.locationField,
      geohashField: PostLocationFirestore.geohashField,
      geopointFrom: geopointFrom,
    );

    return posts
        .map((docSnap) => PostFirestore.fromDb(docSnap.documentSnapshot))
        .where((post) {
      // We need to filter the posts because the query is not exact
      final postPoint = post.location.geoPoint;
      return geoFirePoint.distanceBetweenInKm(geopoint: postPoint) <= radius;
    }).toList();
  }

  /// This method will retrieve all the posts belonging to a given user
  Future<List<PostFirestore>> getUserPosts(UserIdFirestore userId) async {
    final userPosts = await _collectionRef
        .where(PostData.ownerIdField, isEqualTo: userId.value)
        .get();

    return userPosts.docs.map((data) => PostFirestore.fromDb(data)).toList();
  }

  Map<String, dynamic> _geoFirePointToDataDb(GeoFirePoint geoFirePoint) {
    return {
      PostLocationFirestore.geoPointField:
          geoFirePoint.data[PostLocationFirestore.geoPointField],
      PostLocationFirestore.geohashField:
          geoFirePoint.data[PostLocationFirestore.geohashField],
    };
  }
}

final postRepositoryProvider = Provider<PostRepositoryService>(
  (ref) => PostRepositoryService(
    firestore: ref.watch(firestoreProvider),
  ),
);
