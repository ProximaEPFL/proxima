import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/database/user_comment/user_comment_data.dart";

import "../../../mocks/data/user_comment_data.dart";

void main() {
  group("Testing user comment data", () {
    late UserCommentDataGenerator userCommentDataGenerator;

    setUp(() {
      userCommentDataGenerator = UserCommentDataGenerator();
    });

    test("hash overrides correctly", () {
      final userCommentData =
          userCommentDataGenerator.generateUserCommentData();

      final expectedHash = Object.hash(
        userCommentData.parentPostId,
        userCommentData.content,
      );
      final actualHash = userCommentData.hashCode;
      expect(actualHash, expectedHash);
    });

    test("equality overrides correctly", () {
      final userCommentData =
          userCommentDataGenerator.generateUserCommentData();

      final otherUserCommentData = UserCommentData(
        parentPostId: userCommentData.parentPostId,
        content: userCommentData.content,
      );
      expect(userCommentData, otherUserCommentData);
    });

    test("fromDbData throw error when missing fields", () {
      // The data is missing the content field
      final data = <String, dynamic>{
        UserCommentData.parentPostIdField: "parent_post_id",
      };

      expect(
        () => UserCommentData.fromDbData(data),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
