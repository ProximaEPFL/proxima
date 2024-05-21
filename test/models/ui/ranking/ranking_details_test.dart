import "package:collection/collection.dart";
import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/ui/ranking/ranking_details.dart";
import "package:proxima/models/ui/ranking/ranking_element_details.dart";

import "../../../mocks/data/firestore_user.dart";

void main() {
  group("hash and == works", () {
    late List<RankingElementDetails> listRankingElementDetails;

    setUp(() {
      final usersList = FirestoreUserGenerator.generateUserData(5);
      listRankingElementDetails = usersList
          .mapIndexed(
            (index, user) => RankingElementDetails(
              userDisplayName: user.displayName,
              userUserName: user.username,
              centauriPoints: user.centauriPoints,
              userRank: index + 1,
            ),
          )
          .toList();
    });

    test("hash", () {
      final userRankingElementDetail = RankingElementDetails(
        userDisplayName: testingUserData.displayName,
        userUserName: testingUserData.username,
        centauriPoints: 10,
        userRank: 6,
      );

      final rankingDetails = RankingDetails(
        userRankElementDetails: userRankingElementDetail,
        rankElementDetailsList: listRankingElementDetails,
      );

      final expectedHash = Object.hash(
        rankingDetails.userRankElementDetails,
        rankingDetails.rankElementDetailsList,
      );

      final actualHash = rankingDetails.hashCode;

      expect(actualHash, expectedHash);
    });

    test("==", () {
      final userRankingElementDetail = RankingElementDetails(
        userDisplayName: testingUserData.displayName,
        userUserName: testingUserData.username,
        centauriPoints: 10,
        userRank: 6,
      );

      final rankingDetails1 = RankingDetails(
        userRankElementDetails: userRankingElementDetail,
        rankElementDetailsList: listRankingElementDetails,
      );

      final rankingDetails2 = RankingDetails(
        userRankElementDetails: userRankingElementDetail,
        rankElementDetailsList: listRankingElementDetails,
      );

      expect(rankingDetails1 == rankingDetails2, isTrue);
    });

    test("!= userRankElementDetails", () {
      final userRankingElementDetail1 = RankingElementDetails(
        userDisplayName: testingUserData.displayName,
        userUserName: testingUserData.username,
        centauriPoints: 10,
        userRank: 6,
      );

      final rankingDetails1 = RankingDetails(
        userRankElementDetails: userRankingElementDetail1,
        rankElementDetailsList: listRankingElementDetails,
      );

      final userRankingElementDetail2 = RankingElementDetails(
        userDisplayName: testingUserData.displayName,
        userUserName: testingUserData.username,
        centauriPoints: 12,
        userRank: 7,
      );

      final rankingDetails2 = RankingDetails(
        userRankElementDetails: userRankingElementDetail2,
        rankElementDetailsList: listRankingElementDetails,
      );

      expect(rankingDetails1 == rankingDetails2, isFalse);
    });

    test("!= rankingElementDetails", () {
      final userRankingElementDetail = RankingElementDetails(
        userDisplayName: testingUserData.displayName,
        userUserName: testingUserData.username,
        centauriPoints: 10,
        userRank: 6,
      );

      final rankingDetails1 = RankingDetails(
        userRankElementDetails: userRankingElementDetail,
        rankElementDetailsList: listRankingElementDetails,
      );

      final userList2 = FirestoreUserGenerator.generateUserData(3);
      final listRankingElementDetails2 = userList2
          .mapIndexed(
            (index, user) => RankingElementDetails(
              userDisplayName: user.displayName,
              userUserName: user.username,
              centauriPoints: user.centauriPoints,
              userRank: index + 1,
            ),
          )
          .toList();

      final rankingDetails2 = RankingDetails(
        userRankElementDetails: userRankingElementDetail,
        rankElementDetailsList: listRankingElementDetails2,
      );

      expect(rankingDetails1 == rankingDetails2, isFalse);
    });
  });

  test(
      "constructor should yield exception if a userRank is null in rankElementDetailsList",
      () {
    final userRankingElementDetail = RankingElementDetails(
      userDisplayName: testingUserData.displayName,
      userUserName: testingUserData.username,
      centauriPoints: 10,
      userRank: 6,
    );

    final usersList = FirestoreUserGenerator.generateUserData(5);
    final listRankingElementDetails = usersList
        .mapIndexed(
          (index, user) => RankingElementDetails(
            userDisplayName: user.displayName,
            userUserName: user.username,
            centauriPoints: user.centauriPoints,
            userRank: index == 1 ? null : index + 1,
          ),
        )
        .toList();

    expect(
      () => {
        RankingDetails(
          userRankElementDetails: userRankingElementDetail,
          rankElementDetailsList: listRankingElementDetails,
        ),
      },
      throwsAssertionError,
    );
  });
}
