import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/ui/post_overview.dart";

import "../../../mocks/data/post_overview.dart";
import "../../../mocks/providers/provider_post_page.dart";
import "../../../mocks/services/setup_firebase_mocks.dart";

void main() {
  late ProviderScope emptyPostPageWidget;
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

    emptyPostPageWidget = emptyPostPageProvider;
  });

  group("Distances and Timing values", () {
    testWidgets("Check correct distance on basic post", (tester) async {
      await tester.pumpWidget(emptyPostPageWidget);
      await tester.pumpAndSettle();

      final post = testPosts.first;
      final actualDistanceText = "${post.distance}m away";

      final distanceDisplay = find.text(actualDistanceText);

      expect(distanceDisplay, findsOneWidget);
    });

    testWidgets("Check correct distance on custom post", (tester) async {
      await tester.pumpWidget(customPostOverviewPage(customPost));
      await tester.pumpAndSettle();

      final actualDistanceText = "${customPost.distance}m away";

      final distanceDisplay = find.text(actualDistanceText);

      expect(distanceDisplay, findsOneWidget);
    });
  });
}
