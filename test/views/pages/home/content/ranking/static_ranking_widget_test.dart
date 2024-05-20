import "package:flutter_test/flutter_test.dart";
import "package:proxima/views/components/content/publication_header/user_profile_pop_up.dart";
import "package:proxima/views/pages/home/content/ranking/components/ranking_widget.dart";

import "../../../../../mocks/providers/provider_homepage.dart";

void main() {
  group("Widgets display", () {
    testWidgets(
      "Display ranking elements",
      (tester) async {
        await tester.pumpWidget(nonEmptyHomePageProvider);
        await tester.pumpAndSettle();

        // Navigate to the ranking page
        await tester.tap(find.text("Ranking"));
        await tester.pumpAndSettle();

        // Check that the ranking widget is displayed
        final rankingWidget = find.byType(RankingWidget);
        expect(rankingWidget, findsOneWidget);

        // Check that the ranking list is displayed
        final rankingListWidget = find.byKey(RankingWidget.rankingListKey);
        expect(rankingListWidget, findsOneWidget);

        // Check that the user ranking card is displayed
        final userRankingCard = find.byKey(RankingWidget.userRankingCardKey);
        expect(userRankingCard, findsOneWidget);

        // Click on the user ranking card
        await tester.tap(userRankingCard);
        await tester.pumpAndSettle();

        // Check that the profile page pop up is displayed
        final profilePopUp = find.byType(UserProfilePopUp);
        expect(profilePopUp, findsOneWidget);
      },
    );
  });
}
