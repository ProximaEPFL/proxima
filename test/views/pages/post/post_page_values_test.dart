import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

import "../../../mocks/data/post_overview.dart";
import "../../../mocks/providers/provider_post_page.dart";
import "../../../mocks/services/setup_firebase_mocks.dart";

void main() {
  late ProviderScope emptyPostPageWidget;

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
  });
}
