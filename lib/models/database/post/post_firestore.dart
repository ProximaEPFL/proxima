import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/foundation.dart";
import "package:proxima/models/database/post/post_data.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/post/post_location_firestore.dart";

@immutable
class PostFirestore {
  static const collectionName = "posts";

  /// The id is not stored in a field because it already
  /// corresponds to the document id on firestore
  final PostIdFirestore id;

  /// The post location is not stored in the [PostData] because it
  /// is exclusively managed by the repository (in particular, it is the
  /// responsability of the repository to create it when adding a post)
  final PostLocationFirestore location;
  static const String locationField = "location";

  final PostData data;

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
        id: PostIdFirestore(value: docSnap.id),
        location: PostLocationFirestore.fromDbData(data[locationField]),
        data: PostData.fromDbData(data),
      );
    } catch (e) {
      if (e is TypeError) {
        throw FormatException("Cannot parse post document: ${e.toString()}");
      } else {
        rethrow;
      }
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PostFirestore &&
        other.id == id &&
        other.location == location &&
        other.data == data;
  }

  @override
  int get hashCode {
    return Object.hash(id, location, data);
  }
}
