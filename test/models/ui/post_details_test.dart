import "package:flutter_test/flutter_test.dart";

import "../../mocks/data/post_overview.dart";

void main() {
  group("Post Overview testing", () {
    test("hash overrides correctly", () {
      final postDetails = testPosts[0];

      final expectedHash = Object.hash(
        postDetails.postId,
        postDetails.title,
        postDetails.description,
        postDetails.voteScore,
        postDetails.commentNumber,
        postDetails.ownerDisplayName,
        postDetails.ownerUsername,
        postDetails.ownerCentauriPoints,
        postDetails.publicationDate,
        postDetails.distance,
        postDetails.isChallenge,
        postDetails.hasUserCommented,
      );

      final actualHash = postDetails.hashCode;

      expect(actualHash, expectedHash);
    });

    test("equality overrides correctly", () {
      final postDetails = testPosts[0];

      final postDetailsCopy = testPosts[0];

      expect(postDetails, postDetailsCopy);
    });
  });
}
