import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/foundation.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";

@immutable
class CommentData {
  final UserIdFirestore ownerId;
  static const String ownerIdField = "ownerId";

  final PostIdFirestore parentPostId;
  static const String parentPostIdField = "parentPostId";

  final Timestamp publicationTime;
  static const publicationTimeField = "publicationTime";

  final String content;
  static const contentField = "content";

  const CommentData({
    required this.ownerId,
    required this.parentPostId,
    required this.publicationTime,
    required this.content,
  });

  /// This method will create an instance of [CommentData] from the
  /// data map [data] that comes from firestore
  factory CommentData.fromDbData(Map<String, dynamic> data) {
    try {
      return CommentData(
        ownerId: UserIdFirestore(value: data[ownerIdField]),
        parentPostId: PostIdFirestore(value: data[parentPostIdField]),
        publicationTime: data[publicationTimeField],
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
      parentPostIdField: parentPostId.value,
      publicationTimeField: publicationTime,
      contentField: content,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CommentData &&
        other.ownerId == ownerId &&
        other.parentPostId == parentPostId &&
        other.publicationTime == publicationTime &&
        other.content == content;
  }

  @override
  int get hashCode {
    return Object.hash(ownerId, parentPostId, publicationTime, content);
  }
}
