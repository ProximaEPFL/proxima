import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/users_ranking_view_model.dart";
import "package:proxima/views/components/content/publication_header/user_profile_pop_up.dart";
import "package:proxima/views/pages/home/content/ranking/components/ranking_widget.dart";
import "package:proxima/views/pages/home/content/ranking/ranking_page.dart";

import "../../../../../mocks/data/firestore_user.dart";
import "../../../../../mocks/providers/provider_ranking.dart";

void main() {
  group("Ranking widgets display with view model", () {
    late Widget rankingPage;

    setUp(() async {
      final fakeFirestore = FakeFirebaseFirestore();
      await FirestoreUserGenerator.addUsers(
        fakeFirestore,
        UsersRankingViewModel.rankingLimit * 2,
      );

      final rankingContainer = await rankingProviderContainer(fakeFirestore);
      rankingPage = MaterialApp(
        home: UncontrolledProviderScope(
          container: rankingContainer,
          child: const RankingPage(),
        ),
      );
    });

    testWidgets(
      "Display ranking elements correctly",
      (tester) async {
        await tester.pumpWidget(rankingPage);
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
