import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/views/components/content/user_profile_pop_up.dart";
import "package:proxima/views/pages/home/content/ranking/components/ranking_card.dart";
import "package:proxima/views/pages/home/content/ranking/components/ranking_list.dart";

import "../../../../../mocks/data/ranking_data.dart";
import "../../../../../mocks/overrides/override_user_centauri_points_view_model.dart";

void main() {
  group("Widgets display", () {
    testWidgets(
      "Display ranking elements",
      (tester) async {
        final rankingListWidget = ProviderScope(
          overrides: [
            ...mockUserCentauriPointsViewModelZeroCentauriOverride,
          ],
          child: MaterialApp(
            home: RankingList(
              rankingDetails: mockRankingDetailsWithtestUser,
              onRefresh: () async {},
            ),
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

        // Click on the first user ranking card
        await tester.tap(rankingCards.first);
        await tester.pumpAndSettle();

        // Check that the profile page pop up is displayed
        final profilePopUp = find.byType(UserProfilePopUp);
        expect(profilePopUp, findsOneWidget);
      },
    );
  });
}
