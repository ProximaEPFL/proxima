import "dart:math";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/user_comment/user_comment_data.dart";

/// This class is responsible for generating mock [UserCommentData] instances.
class UserCommentDataGenerator {
  final Random _random;

  UserCommentDataGenerator({int seed = 0}) : _random = Random(seed);

  /// Generate a list of [UserCommentData] instances with random data.
  List<UserCommentData> generateUserCommentDatas(int count) {
    return List.generate(count, (_) => generateUserCommentData());
  }

  /// Create a random mock [UserCommentData] instance.
  /// The [parentPostId], [content] or [publicationTime] can be provided to avoid randomness.
  UserCommentData generateUserCommentData({
    PostIdFirestore? parentPostId,
    String? content,
    Timestamp? publicationTime,
  }) {
    return UserCommentData(
      parentPostId: parentPostId ??
          PostIdFirestore(value: "parent_post_id_${_random.nextInt(100)}"),
      content: content ?? "content_${_random.nextInt(100)}",
      publicationTime: publicationTime ??
          Timestamp.fromMillisecondsSinceEpoch(_random.nextInt(1000000000)),
    );
  }
}
