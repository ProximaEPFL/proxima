import "package:cloud_firestore/cloud_firestore.dart";
import "package:geoflutterfire_plus/geoflutterfire_plus.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_data.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/post/post_location_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/services/database/comment_repository_service.dart";
import "package:proxima/services/database/firestore_service.dart";
import "package:proxima/services/database/upvote_repository_service.dart";

/// This repository service is responsible for managing the posts in the database
class PostRepositoryService {
  final FirebaseFirestore _firestore;
  final CollectionReference<Map<String, dynamic>> _collectionRef;
  final CommentRepositoryService _commentRepository;
  final UpvoteRepositoryService<PostIdFirestore> _upvoteRepository;

  PostRepositoryService({
    required FirebaseFirestore firestore,
  })  : _firestore = firestore,
        _collectionRef = firestore.collection(PostFirestore.collectionName),
        _commentRepository = CommentRepositoryService(firestore: firestore),
        _upvoteRepository =
            UpvoteRepositoryService.postUpvoteRepository(firestore);

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

  /// This method deletes the post with id [postId] from the database.
  /// This means removing the corresponding document, and all the
  /// subcollections.
  Future<void> deletePost(PostIdFirestore postId) async {
    final batch = _firestore.batch();

    await _commentRepository.deleteAllComments(postId, batch);
    await _upvoteRepository.deleteAllUpvotes(postId, batch);
    batch.delete(_collectionRef.doc(postId.value));

    await batch.commit();
  }

  /// This method returns true if the post with id [postId] exists in the database
  /// and false otherwise
  Future<bool> postExists(PostIdFirestore postId) async {
    final docSnap = await _collectionRef.doc(postId.value).get();
    return docSnap.exists;
  }

  /// This method returns the post with id [postId] from the database
  Future<PostFirestore> getPost(PostIdFirestore postId) async {
    final docSnap = await _collectionRef.doc(postId.value).get();

    return PostFirestore.fromDb(docSnap);
  }

  /// This method will retrieve all the posts that
  /// are within a maximum radius of [maxRadius]
  /// and a minimum radius of [minRadius]
  /// from the geo point [point] in the database
  /// And then those posts are returned
  /// [minRadius] is optional and 0 by default
  Future<List<PostFirestore>> getNearPosts(
    GeoPoint point,
    double maxRadius, [
    double minRadius = 0,
  ]) async {
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
      radiusInKm: maxRadius,
      field: PostFirestore.locationField,
      geohashField: PostLocationFirestore.geohashField,
      geopointFrom: geopointFrom,
    );

    return posts
        .map((docSnap) => PostFirestore.fromDb(docSnap.documentSnapshot))
        .where((post) {
      // We need to filter the posts because the query is not exact
      final postPoint = post.location.geoPoint;

      double distance = geoFirePoint.distanceBetweenInKm(geopoint: postPoint);
      return minRadius <= distance && distance <= maxRadius;
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
