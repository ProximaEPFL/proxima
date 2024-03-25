import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/foundation.dart";
import "package:geoflutterfire2/geoflutterfire2.dart";
import "package:proxima/services/geolocation_service.dart";

@immutable
class PostLocationFirestore {
  final GeoPoint geoPoint;
  final String geohash;

  /// Do not change !
  /// The [GeoFlutterFire] library that is used to perform the geo queries uses
  /// hardcoded field name values in its implementation and does not provide
  /// methods to automatically parse the point data. Thus we must manually specify
  /// the field name for the geo point and the geo hash
  static const String geoPointField = "geopoint"; // Do not change
  static const String geohashField = "geohash"; // Do not change

  const PostLocationFirestore({
    required this.geoPoint,
    required this.geohash,
  });

  /// Parses the data from a firestore document
  factory PostLocationFirestore.fromDbData(Map<String, dynamic> data) {
    try {
      return PostLocationFirestore(
        geoPoint: data[geoPointField],
        geohash: data[geohashField],
      );
    } catch (e) {
      if (e is TypeError) {
        throw Exception("Cannot parse post location document: ${e.toString()}");
      } else {
        rethrow;
      }
    }
  }
}

@immutable
class PostFirestore {
  /// The id is not stored in a field because it already
  /// corresponds to the document id on firestore
  final String id;

  /// The post location is not stored in the [PostFirestoreData] because it
  /// is exclusively managed by the repository (in particular, it is the
  /// responsability of the repository to create it when adding a post)
  final PostLocationFirestore location;
  static const String locationField = "location";

  final PostFirestoreData data;

  const PostFirestore({
    required this.id,
    required this.location,
    required this.data,
  });

  /// Parses the data from a firestore document
  factory PostFirestore.fromDb(DocumentSnapshot docSnap) {
    if (!docSnap.exists) {
      throw Exception("Post document does not exist");
    }

    try {
      final data = docSnap.data() as Map<String, dynamic>;

      return PostFirestore(
        id: docSnap.id,
        location: PostLocationFirestore.fromDbData(data[locationField]),
        data: PostFirestoreData.fromDbData(data),
      );
    } catch (e) {
      if (e is TypeError) {
        throw Exception("Cannot parse post document: ${e.toString()}");
      } else {
        rethrow;
      }
    }
  }
}

@immutable
class PostFirestoreData {
  final String ownerId;
  static const String ownerIdField = "ownerId";

  final String title;
  static const String titleField = "title";

  final String description;
  static const String descriptionField = "description";

  final Timestamp publicationTime;
  static const String publicationTimeField = "publicationTime";

  final int voteScore;
  static const String voteScoreField = "voteScore";

  const PostFirestoreData({
    required this.ownerId,
    required this.title,
    required this.description,
    required this.publicationTime,
    required this.voteScore,
  });

  /// Parses the data from a firestore document
  factory PostFirestoreData.fromDbData(Map<String, dynamic> data) {
    try {
      return PostFirestoreData(
        ownerId: data[ownerIdField],
        title: data[titleField],
        description: data[descriptionField],
        publicationTime: data[publicationTimeField],
        voteScore: data[voteScoreField],
      );
    } catch (e) {
      if (e is TypeError) {
        throw Exception("Cannot parse post document: ${e.toString()}");
      } else {
        rethrow;
      }
    }
  }

  Map<String, dynamic> toDbData() {
    return {
      ownerIdField: ownerId,
      titleField: title,
      descriptionField: description,
      publicationTimeField: publicationTime,
      voteScoreField: voteScore,
    };
  }
}

class PostRepository {
  final GeoFlutterFire _geoFire;
  final GeoLocationService _geoLocationService;

  static const collectionName = "posts";
  final CollectionReference _collectionRef;

  static const double kmPostRadius = 0.1;

  PostRepository({
    required FirebaseFirestore firestore,
    required GeoFlutterFire geoFire,
    required GeoLocationService geoLocationService,
  })  : _collectionRef = firestore.collection(collectionName),
        _geoFire = geoFire,
        _geoLocationService = geoLocationService;

  /// Get the posts near the current location of the user
  /// The radius is defined by [kmPostRadius]
  Future<List<PostFirestore>> getNearPosts() async {
    final point = await _getCurrentGeoFirePoint();

    return _getPostsNearLocation(point, kmPostRadius);
  }

  /// Get a post by its id
  Future<PostFirestore> getPost(String postId) async {
    final docSnap = await _collectionRef.doc(postId).get();

    return PostFirestore.fromDb(docSnap);
  }

  /// Adds a post at the current location of the user
  Future<void> addPost(PostFirestoreData postData) async {
    final point = await _getCurrentGeoFirePoint();

    return _addPostAtLocation(point, postData);
  }

  /// Deletes a post by its id
  Future<void> deletePost(String postId) async {
    await _collectionRef.doc(postId).delete();
  }

  Future<void> upVotePost(String postId) {
    // Advice for implementation: use firestore transactions to ensure
    // atomicity of the operation
    return Future.error("Not implemented");
  }

  Future<void> downVotePost(String postId) {
    // Advice for implementation: use firestore transactions to ensure
    // atomicity of the operation
    return Future.error("Not implemented");
  }

  Future<void> _addPostAtLocation(
    GeoFirePoint point,
    PostFirestoreData postData,
  ) async {
    // The `point.data` returns a Map<String, dynamic> consistent with the
    // class [PostLocationFirestore]. This is because the field name values
    // are hardcoded in the [GeoFlutterFire] library

    await _collectionRef.add({
      PostFirestore.locationField: point.data,
      ...postData.toDbData(),
    });
  }

  Future<List<PostFirestore>> _getPostsNearLocation(
    GeoFirePoint point,
    double radius,
  ) async {
    final posts = await _geoFire
        .collection(collectionRef: _collectionRef)
        .within(
          center: point,
          radius: radius,
          field: PostFirestore.locationField,
          strictMode: true,
        )
        .first;

    return posts.map((docSnap) => PostFirestore.fromDb(docSnap)).toList();
  }

  Future<GeoFirePoint> _getCurrentGeoFirePoint() async {
    final currentPosition = await _geoLocationService.getCurrentPosition();
    return GeoFirePoint(
      currentPosition.latitude,
      currentPosition.longitude,
    );
  }
}
