import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/foundation.dart";

@immutable
class PostLocationFirestore {
  final GeoPoint geoPoint;
  final String geohash;

  static const String geoPointField = "geopoint";
  static const String geohashField = "geohash";

  const PostLocationFirestore({
    required this.geoPoint,
    required this.geohash,
  });

  /// This method will create an instance of [PostLocationFirestore] from the
  /// data map [data] that comes from firestore
  factory PostLocationFirestore.fromDbData(Map<String, dynamic> data) {
    try {
      return PostLocationFirestore(
        geoPoint: data[geoPointField],
        geohash: data[geohashField],
      );
    } catch (e) {
      if (e is TypeError) {
        throw FormatException(
          "Cannot parse post location document: ${e.toString()}",
        );
      } else {
        rethrow;
      }
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PostLocationFirestore &&
        other.geoPoint == geoPoint &&
        other.geohash == geohash;
  }

  @override
  int get hashCode => Object.hash(geoPoint, geohash);
}
