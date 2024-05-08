import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/ui/post_overview.dart";
import "package:proxima/views/pages/post/post_page_widget/complete_post_widget.dart";

import "../../../mocks/data/post_overview.dart";
import "../../../mocks/providers/provider_post_page.dart";
import "../../../mocks/services/setup_firebase_mocks.dart";

void main() {
  // Custom post for testing specific date and distances
  final customPost = PostOverview(
    postId: const PostIdFirestore(value: "post_1"),
    title: "title",
    description: "description",
    voteScore: 1,
    commentNumber: 5,
    ownerDisplayName: "owner",
    publicationDate: DateTime.utc(1999),
    distance: 100,
  );

  setUp(() async {
    setupFirebaseAuthMocks();
  });

  group("Post Distances and Timing values", () {
    testWidgets("Check correct distance on basic post", (tester) async {
      await tester.pumpWidget(emptyPostPageProvider);
      await tester.pumpAndSettle();

      final post = testPosts.first;
      final expectedDistanceText = "${post.distance}m away";

      final distanceDisplay = find.text(expectedDistanceText);

      expect(distanceDisplay, findsOneWidget);
    });

    testWidgets("Check correct distance on custom post", (tester) async {
      await tester.pumpWidget(customPostOverviewPage(customPost));
      await tester.pumpAndSettle();

      final expectedDistanceText = "${customPost.distance}m away";

      final appBar = find.byType(AppBar);
      expect(appBar, findsOneWidget);

      final actualDistanceDisplayed = find.descendant(
        of: appBar,
        matching: find.text(expectedDistanceText),
      );

      expect(actualDistanceDisplayed, findsOneWidget);
    });

    testWidgets("Check correct timing on basic post, special 'now' case",
        (tester) async {
      await tester.pumpWidget(customPostOverviewPage(testPosts.first));
      await tester.pumpAndSettle();

      const expectedTimeValue = "now";

      final postUserBar = find.byKey(CompletePostWidget.postUserBarKey);
      expect(postUserBar, findsOneWidget);

      final actualTimeDisplayed = find.descendant(
        of: postUserBar,
        matching: find.text(expectedTimeValue),
      );

      expect(actualTimeDisplayed, findsOneWidget);
    });
  });
}
