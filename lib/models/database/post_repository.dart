import "package:cloud_firestore/cloud_firestore.dart";

class PostFirestore {
  /// The id is not stored in a field because it already
  /// corresponds to the document id on firestore
  final String id;

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

  final String geoHash;
  static const String geoHashField = "geoHash";

  final Timestamp publicationTime;
  static const String publicationTimeField = "publicationTime";

  final int voteScore;
  static const String voteScoreField = "voteScore";

  PostFirestore({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.longitude,
    required this.latitude,
    required this.geoHash,
    required this.publicationTime,
    required this.voteScore,
  });

  factory PostFirestore.fromDb(DocumentSnapshot docSnap) {
    if (!docSnap.exists) {
      throw Exception("Post document does not exist");
    }

    try {
      final data = docSnap.data() as Map<String, dynamic>;

      return PostFirestore(
        id: docSnap.id,
        ownerId: data[ownerIdField],
        title: data[titleField],
        description: data[descriptionField],
        longitude: data[longitudeField],
        latitude: data[latitudeField],
        geoHash: data[geoHashField],
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

  Map<String, dynamic> toDb() {
    return {
      ownerIdField: ownerId,
      titleField: title,
      descriptionField: description,
      longitudeField: longitude,
      latitudeField: latitude,
      geoHashField: geoHash,
      publicationTimeField: publicationTime,
      voteScoreField: voteScore,
    };
  }
}
