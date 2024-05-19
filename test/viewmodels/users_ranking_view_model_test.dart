import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/users_ranking_view_model.dart";

import "../mocks/data/firestore_user.dart";
import "../mocks/providers/provider_ranking.dart";

void main() {
  group("User ranking view model testing", () {
    late FakeFirebaseFirestore fakeFirestore;
    late ProviderContainer rankingContainer;

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      await FirestoreUserGenerator.addUsers(
        fakeFirestore,
        UsersRankingViewModel.rankingLimit * 2,
      );

      rankingContainer = rankingProviderContainer(fakeFirestore);
    });

    test("Correct number of users returned", () async {
      final ranking =
          await rankingContainer.read(usersRankingViewModelProvider.future);

      expect(
        ranking.rankElementDetailsList.length,
        UsersRankingViewModel.rankingLimit,
      );
    });

    test("Logged in user has correct values", () async {
      final ranking =
          await rankingContainer.read(usersRankingViewModelProvider.future);
      final currentUserRanking = ranking.userRankElementDetails;

      expect(
        currentUserRanking.userDisplayName,
        testingUserData.displayName,
      );
      expect(
        currentUserRanking.userUserName,
        testingUserData.username,
      );
      expect(
        currentUserRanking.centauriPoints,
        testingUserData.centauriPoints,
      );
      expect(
        currentUserRanking.userRank,
        isNull,
      );
    });
  });
}
