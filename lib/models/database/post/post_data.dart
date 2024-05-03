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

  final int commentCount;
  static const String commentCountField = "commentCount";

  const PostData({
    required this.ownerId,
    required this.title,
    required this.description,
    required this.publicationTime,
    required this.voteScore,
    required this.commentCount,
  });

  /// This method will create an instance of [PostData] from the
  /// data map [data] that comes from firestore
  factory PostData.fromDbData(Map<String, dynamic> data) {
    try {
      return PostData(
        ownerId: UserIdFirestore(value: data[ownerIdField]),
        title: data[titleField],
        description: data[descriptionField],
        publicationTime: data[publicationTimeField],
        voteScore: data[voteScoreField],
        commentCount: data[commentCountField] ?? 0,
      );
    } catch (e) {
      if (e is TypeError) {
        throw FormatException("Cannot parse post document: ${e.toString()}");
      } else {
        rethrow;
      }
    }
  }

  /// This method will create a map from the current instance of [PostData]
  /// to be stored in firestore
  Map<String, dynamic> toDbData() {
    return {
      ownerIdField: ownerId.value,
      titleField: title,
      descriptionField: description,
      publicationTimeField: publicationTime,
      voteScoreField: voteScore,
      commentCountField: commentCount,
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
        other.voteScore == voteScore &&
        other.commentCount == commentCount;
  }

  @override
  int get hashCode {
    return Object.hash(
      ownerId,
      title,
      description,
      publicationTime,
      voteScore,
      commentCount,
    );
  }
}
