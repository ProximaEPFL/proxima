import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/foundation.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";

/// This class represents the data of a comment in the firestore database
@immutable
class CommentData {
  final UserIdFirestore ownerId;
  static const String ownerIdField = "ownerId";

  final Timestamp publicationTime;
  static const publicationTimeField = "publicationTime";

  final int voteScore;
  static const voteScoreField = "voteScore";

  final String content;
  static const contentField = "content";

  const CommentData({
    required this.ownerId,
    required this.publicationTime,
    required this.voteScore,
    required this.content,
  });

  /// This method will create an instance of [CommentData] from the
  /// data map [data] that comes from firestore
  factory CommentData.fromDbData(Map<String, dynamic> data) {
    try {
      return CommentData(
        ownerId: UserIdFirestore(value: data[ownerIdField]),
        publicationTime: data[publicationTimeField],
        voteScore: data[voteScoreField],
        content: data[contentField],
      );
    } catch (e) {
      if (e is TypeError) {
        throw FormatException("Cannot parse comment document: ${e.toString()}");
      } else {
        rethrow;
      }
    }
  }

  /// This method will create a map from the current instance of [CommentData]
  /// to be stored in firestore
  Map<String, dynamic> toDbData() {
    return {
      ownerIdField: ownerId.value,
      publicationTimeField: publicationTime,
      voteScoreField: voteScore,
      contentField: content,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CommentData &&
        other.ownerId == ownerId &&
        other.publicationTime == publicationTime &&
        other.voteScore == voteScore &&
        other.content == content;
  }

  @override
  int get hashCode {
    return Object.hash(ownerId, publicationTime, voteScore, content);
  }
}
