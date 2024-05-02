import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/database/comment/comment_data.dart";

import "../../../mocks/data/comment_data.dart";

void main() {
  group("Testing comment data", () {
    late CommentDataGenerator commentDataGenerator;

    setUp(() {
      commentDataGenerator = CommentDataGenerator();
    });

    test("hash overrides correctly", () {
      final commentData = commentDataGenerator.createRandomCommentData();

      final expectedHash = Object.hash(
        commentData.ownerId,
        commentData.publicationTime,
        commentData.voteScore,
        commentData.content,
      );

      final actualHash = commentData.hashCode;

      expect(actualHash, expectedHash);
    });

    test("equality overrides correctly", () {
      final commentData = commentDataGenerator.createRandomCommentData();

      final otherCommentData = CommentData(
        content: commentData.content,
        ownerId: commentData.ownerId,
        publicationTime: commentData.publicationTime,
        voteScore: commentData.voteScore,
      );

      expect(commentData, otherCommentData);
    });

    test("fromDbData throw error when missing fields", () {
      // The data is missing the voteScore field
      final data = <String, dynamic>{
        CommentData.contentField: "content",
        CommentData.ownerIdField: "owner_id",
        CommentData.publicationTimeField:
            Timestamp.fromMillisecondsSinceEpoch(4564654),
      };

      expect(
        () => CommentData.fromDbData(data),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
