import "package:cloud_firestore/cloud_firestore.dart";
import "package:collection/collection.dart";
import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/user/user_data.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
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

      rankingContainer =
          await rankingProviderContainerWithTestingUser(fakeFirestore);
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

    test("View model returns a descending order with correct ranks", () async {
      final ranking =
          await rankingContainer.read(usersRankingViewModelProvider.future);
      final leaderboard = ranking.rankElementDetailsList;

      // Check that all ranks are non null and correct
      final lastRank =
          leaderboard.map((e) => e.userRank!).reduce((value, element) {
        expect(value + 1, element);
        return element;
      });
      expect(lastRank, UsersRankingViewModel.rankingLimit);

      // Check that all centauri points are in descending order
      final centauris = leaderboard.map((e) => e.centauriPoints);
      expect(centauris.isSorted((a, b) => -a.compareTo(b)), isTrue);
    });

    test("View model refreshes correctly", () async {
      final ranking =
          await rankingContainer.read(usersRankingViewModelProvider.future);
      final topUser = ranking.rankElementDetailsList.first;

      // Create a user with more points than current top user
      final newTopUserFireStore = UserFirestore(
        uid: const UserIdFirestore(value: "my_top_user_uid"),
        data: UserData(
          username: "top user",
          displayName: "top user",
          joinTime: Timestamp.now(),
          centauriPoints: topUser.centauriPoints + 1,
        ),
      );

      await setUserFirestore(
        fakeFirestore,
        newTopUserFireStore,
      );

      // Refresh the viewmodel
      await rankingContainer
          .read(usersRankingViewModelProvider.notifier)
          .refresh();
      // delay for async execution of refresh
      await Future.delayed(Durations.short1);

      // Retrieve the new rankings from viewmodel
      final newRanking =
          await rankingContainer.read(usersRankingViewModelProvider.future);
      final newTopUser = newRanking.rankElementDetailsList.first;

      // Check that the new top user was correctly update
      expect(
        newTopUser.userUserName != topUser.userUserName,
        isTrue,
      );
      expect(
        newTopUser.userUserName,
        newTopUserFireStore.data.username,
      );

      // Check that the old top user is now second
      expect(
        newRanking.rankElementDetailsList[1].userUserName,
        topUser.userUserName,
      );
    });
  });
}
