import "package:flutter_test/flutter_test.dart";

import "../../mocks/data/post_overview.dart";

void main() {
  group("Post Overview testing", () {
    test("hash overrides correctly", () {
      final postOverview = testPosts[0];

      final expectedHash = Object.hash(
        postOverview.postId,
        postOverview.title,
        postOverview.description,
        postOverview.voteScore,
        postOverview.commentNumber,
        postOverview.ownerDisplayName,
        postOverview.publicationTime,
        postOverview.distance,
      );

      final actualHash = postOverview.hashCode;

      expect(actualHash, expectedHash);
    });

    test("equality overrides correctly", () {
      final postOverview = testPosts[0];

      final postOverviewCopy = testPosts[0];

      expect(postOverview, postOverviewCopy);
    });
  });
}
