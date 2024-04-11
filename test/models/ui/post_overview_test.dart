import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/ui/post_overview.dart";

void main() {
  group("Post Overview testing", () {
    test("hash overrides correctly", () {
      const postOverview = PostOverview(
        title: "title",
        description: "description",
        voteScore: 12,
        commentNumber: 3,
        ownerDisplayName: "username",
      );

      final expectedHash = Object.hash(
        postOverview.title,
        postOverview.description,
        postOverview.voteScore,
        postOverview.commentNumber,
        postOverview.ownerDisplayName,
      );

      final actualHash = postOverview.hashCode;

      expect(actualHash, expectedHash);
    });

    test("equality overrides correctly", () {
      const postOverview = PostOverview(
        title: "title",
        description: "description",
        voteScore: 12,
        commentNumber: 3,
        ownerDisplayName: "username",
      );

      const postOverviewCopy = PostOverview(
        title: "title",
        description: "description",
        voteScore: 12,
        commentNumber: 3,
        ownerDisplayName: "username",
      );

      expect(postOverview, postOverviewCopy);
    });
  });
}
