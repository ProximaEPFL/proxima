import "package:proxima/models/database/comment/comment_id_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";

class UserCommentData {
  // The id of the comment under the post.
  final CommentIdFirestore commentId;
  static const String commentIdField = "commentId";

  // The id of the post that the user commented on.
  final PostIdFirestore parentPostId;
  static const String parentPostIdField = "parentPostId";

  /// The reference contains the content of the comment to be displayed.
  /// This is to avoid having to fetch the comment data from the comment
  /// collection under the post every time we want to display the user's comments.
  final String content;
  static const String contentField = "content";

  const UserCommentData({
    required this.commentId,
    required this.parentPostId,
    required this.content,
  });

  /// This method will create an instance of [UserCommentData] from the
  /// data map [data] that comes from firestore
  factory UserCommentData.fromDbData(Map<String, dynamic> data) {
    try {
      return UserCommentData(
        commentId: CommentIdFirestore(value: data[commentIdField]),
        parentPostId: PostIdFirestore(value: data[parentPostIdField]),
        content: data[contentField],
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
      commentIdField: commentId.value,
      parentPostIdField: parentPostId.value,
      contentField: content,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is UserCommentData &&
        other.commentId == commentId &&
        other.parentPostId == parentPostId &&
        other.content == content;
  }

  @override
  int get hashCode => Object.hash(commentId, parentPostId, content);
}
