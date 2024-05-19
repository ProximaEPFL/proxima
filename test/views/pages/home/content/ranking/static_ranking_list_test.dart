import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:proxima/views/components/content/publication_header/user_profile_pop_up.dart";
import "package:proxima/views/pages/home/content/ranking/ranking_card.dart";
import "package:proxima/views/pages/home/content/ranking/ranking_list.dart";

import "../../../../../mocks/data/ranking_data.dart";

void main() {
  testWidgets(
    "Check that all the ranking elements are displayed correctly",
    (tester) async {
      final rankingListWidget = MaterialApp(
        home: RankingList(
          rankingDetails: mockRankingDetailsWithtestUser,
          onRefresh: () async {},
        ),
      );

      await tester.pumpWidget(rankingListWidget);
      await tester.pumpAndSettle();

      // Check that the ranking list is displayed
      final rankingList = find.byType(RankingList);
      expect(rankingList, findsOneWidget);

      // Check that the ranking cards are displayed
      // The additional card is for the current user's ranking card.
      final rankingCards = find.byType(RankingCard);
      expect(
        rankingCards,
        findsNWidgets(mockRankingElementDetailsList.length),
      );

      // Check that the user ranks are displayed
      final userRankTexts = find.byKey(RankingCard.userRankrankTextKey);
      expect(
        userRankTexts,
        findsNWidgets(mockRankingElementDetailsList.length),
      );

      // Check that the user avatar are displayed
      final userAvatars = find.byKey(RankingCard.userRankAvatarKey);
      expect(
        userAvatars,
        findsNWidgets(mockRankingElementDetailsList.length),
      );

      // Check that the display names are displayed
      final userDisplayNameTexts =
          find.byKey(RankingCard.userRankDisplayNameTextKey);
      expect(
        userDisplayNameTexts,
        findsNWidgets(mockRankingElementDetailsList.length),
      );

      // Check that the centauri points are displayed
      final centauriPointsTexts =
          find.byKey(RankingCard.userRankCentauriPointsTextKey);
      expect(
        centauriPointsTexts,
        findsNWidgets(mockRankingElementDetailsList.length),
      );

      //Check that the card color corresponds to the expected color
      const expectedRankOneColor = Color.fromARGB(255, 255, 218, 75);
      const expectedRrankSecondColor = Color.fromARGB(255, 217, 218, 204);
      const expectedRrankThirdColor = Color.fromARGB(255, 229, 153, 137);

      final expectedColorsRank = {
        1: expectedRankOneColor,
        2: expectedRrankSecondColor,
        3: expectedRrankThirdColor,
      };

      expectedColorsRank.forEach(
        (rank, expectedColor) {
          // Check that the color of the rank card containing
          // the user with the rank [rank] is of the right color
          final rankCardTextFinder = find.descendant(
            of: rankingCards,
            matching: find.text(rank.toString()),
          );
          expect(rankCardTextFinder, findsOneWidget);

          // Get the card containing the user with the rank [rank]
          final rankCardFinder = find.ancestor(
            of: rankCardTextFinder,
            matching: find.byType(Card),
          );

          expect(rankCardFinder, findsOneWidget);

          final rankCardWidget = tester.widget(rankCardFinder);

          // Check that the color matches the expected color
          expect((rankCardWidget as Card).color, expectedColor);
        },
      );

      // Click on the first user ranking card
      await tester.tap(rankingCards.first);
      await tester.pumpAndSettle();

      // Check that the profile page pop up is displayed
      final profilePopUp = find.byType(UserProfilePopUp);
      expect(profilePopUp, findsOneWidget);
    },
  );
}
