import "package:cloud_firestore/cloud_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";

/// This class represents the data required to display a user's comment
/// on the user's profile page.
class UserCommentData {
  // The id of the post that the user commented on.
  final PostIdFirestore parentPostId;
  static const String parentPostIdField = "parentPostId";

  /// The reference contains the content and publication time of the comment to be displayed.
  /// This is to avoid having to fetch the comment data from the comment
  /// collection under the post every time we want to display the user's comments.
  final String content;
  static const String contentField = "content";

  final Timestamp publicationTime;
  static const String publicationTimeField = "publicationTime";

  const UserCommentData({
    required this.parentPostId,
    required this.content,
    required this.publicationTime,
  });

  /// This method will create an instance of [UserCommentData] from the
  /// data map [data] that comes from firestore
  factory UserCommentData.fromDbData(Map<String, dynamic> data) {
    try {
      return UserCommentData(
        parentPostId: PostIdFirestore(value: data[parentPostIdField]),
        content: data[contentField],
        publicationTime: data[publicationTimeField],
      );
    } catch (e) {
      if (e is TypeError) {
        throw FormatException(
          "Cannot parse user comment document: ${e.toString()}",
        );
      } else {
        rethrow;
      }
    }
  }

  /// This method will create a map from the current instance of [UserCommentData]
  /// to be stored in firestore
  Map<String, dynamic> toDbData() {
    return {
      parentPostIdField: parentPostId.value,
      contentField: content,
      publicationTimeField: publicationTime,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is UserCommentData &&
        other.parentPostId == parentPostId &&
        other.content == content &&
        other.publicationTime == publicationTime;
  }

  @override
  int get hashCode => Object.hash(parentPostId, content, publicationTime);
}
