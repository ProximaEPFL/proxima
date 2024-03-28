import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/foundation.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";

@immutable
class PostData {
  final UserIdFirestore ownerId;
  static const String ownerIdField = "ownerId";

  final String title;
  static const String titleField = "title";

  final String description;
  static const String descriptionField = "description";

  final Timestamp publicationTime;
  static const String publicationTimeField = "publicationTime";

  final int voteScore;
  static const String voteScoreField = "voteScore";

  const PostData({
    required this.ownerId,
    required this.title,
    required this.description,
    required this.publicationTime,
    required this.voteScore,
  });

  /// Parses the data from a firestore document
  factory PostData.fromDbData(Map<String, dynamic> data) {
    try {
      return PostData(
        ownerId: UserIdFirestore(value: data[ownerIdField]),
        title: data[titleField],
        description: data[descriptionField],
        publicationTime: data[publicationTimeField],
        voteScore: data[voteScoreField],
      );
    } catch (e) {
      if (e is TypeError) {
        throw FormatException("Cannot parse post document: ${e.toString()}");
      } else {
        rethrow;
      }
    }
  }

  Map<String, dynamic> toDbData() {
    return {
      ownerIdField: ownerId.value,
      titleField: title,
      descriptionField: description,
      publicationTimeField: publicationTime,
      voteScoreField: voteScore,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PostData &&
        other.ownerId == ownerId &&
        other.title == title &&
        other.description == description &&
        other.publicationTime == publicationTime &&
        other.voteScore == voteScore;
  }

  @override
  int get hashCode {
    return Object.hash(ownerId, title, description, publicationTime, voteScore);
  }
}
