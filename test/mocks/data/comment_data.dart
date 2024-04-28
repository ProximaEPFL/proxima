import "dart:math";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:proxima/models/database/comment/comment_data.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";

class CommentDataGenerator {
  static List<CommentData> generateCommentData(int count) {
    return List.generate(count, (i) {
      return CommentData(
        content: "content_$i",
        ownerId: UserIdFirestore(value: "owner_id_$i"),
        publicationTime: Timestamp.fromMillisecondsSinceEpoch(1000 * i),
        voteScore: i,
      );
    });
  }

  static CommentData createRandomCommentData({
    String? content,
    UserIdFirestore? ownerId,
    Timestamp? publicationTime,
    int? voteScore,
  }) {
    return CommentData(
      content: content ?? "content_${Random().nextInt(100)}",
      ownerId: ownerId ??
          UserIdFirestore(value: "owner_id_${Random().nextInt(100)}"),
      publicationTime: publicationTime ??
          Timestamp.fromMicrosecondsSinceEpoch(Random().nextInt(1000000)),
      voteScore: voteScore ?? Random().nextInt(100),
    );
  }
}
