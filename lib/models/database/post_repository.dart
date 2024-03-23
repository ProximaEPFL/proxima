import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";

class PostFirestore {
  /// The id is not stored in a field because it already
  /// corresponds to the document id on firestore
  final String id;

  /// The geoHash is not stored in the [PostFirestoreData] because it
  /// is exclusively managed by the repository (in particular, it is the
  /// responsability of the repository to create it when adding a post)
  final String geoHash;
  static const String geoHashField = "geoHash";

  final PostFirestoreData data;

  PostFirestore({
    required this.id,
    required this.geoHash,
    required this.data,
  });

  factory PostFirestore.fromDb(DocumentSnapshot docSnap) {
    if (!docSnap.exists) {
      throw Exception("Post document does not exist");
    }

    try {
      final data = docSnap.data() as Map<String, dynamic>;

      return PostFirestore(
        id: docSnap.id,
        geoHash: data[geoHashField],
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

class PostFirestoreData {
  final String ownerId;
  static const String ownerIdField = "ownerId";

  final String title;
  static const String titleField = "title";

  final String description;
  static const String descriptionField = "description";

  final double longitude;
  static const String longitudeField = "longitude";

  final double latitude;
  static const String latitudeField = "latitude";

  final Timestamp publicationTime;
  static const String publicationTimeField = "publicationTime";

  final int voteScore;
  static const String voteScoreField = "voteScore";

  PostFirestoreData({
    required this.ownerId,
    required this.title,
    required this.description,
    required this.longitude,
    required this.latitude,
    required this.publicationTime,
    required this.voteScore,
  });

  factory PostFirestoreData.fromDbData(Map<String, dynamic> data) {
    try {
      return PostFirestoreData(
        ownerId: data[ownerIdField],
        title: data[titleField],
        description: data[descriptionField],
        longitude: data[longitudeField],
        latitude: data[latitudeField],
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
      longitudeField: longitude,
      latitudeField: latitude,
      publicationTimeField: publicationTime,
      voteScoreField: voteScore,
    };
  }
}

class PostRepository {
  final FirebaseAuth _firebaseAuth;

  static const collectionName = "posts";
  final CollectionReference _collectionRef;

  PostRepository({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _collectionRef = firestore.collection(collectionName),
        _firebaseAuth = firebaseAuth;

  Future<List<PostFirestore>> getNearPosts() {
    return Future.error("Not implemented");
  }

  Future<PostFirestore> getPost(String postId) {
    return Future.error("Not implemented");
  }

  Future<void> addPost(PostFirestoreData postData) {
    return Future.error("Not implemented");
  }

  Future<void> deletePost(String postId) {
    return Future.error("Not implemented");
  }

  Future<void> upVotePost(String postId) {
    return Future.error("Not implemented");
  }

  Future<void> downVotePost(String postId) {
    return Future.error("Not implemented");
  }
}
