import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/models/ui/ranking/ranking_element_details.dart";

import "../../../mocks/data/firestore_user.dart";

void main() {
  group("hash and == works", () {
    test("hash", () {
      final rankingElementDetail = RankingElementDetails(
        userDisplayName: testingUserData.displayName,
        userUserName: testingUserData.username,
        userID: testingUserFirestoreId,
        centauriPoints: 10,
        userRank: 1,
      );

      final expectedHash = Object.hash(
        rankingElementDetail.userDisplayName,
        rankingElementDetail.userUserName,
        rankingElementDetail.userID,
        rankingElementDetail.centauriPoints,
        rankingElementDetail.userRank,
      );

      final actualHash = rankingElementDetail.hashCode;

      expect(actualHash, expectedHash);
    });

    test("==", () {
      final rankingElementDetail1 = RankingElementDetails(
        userDisplayName: testingUserData.displayName,
        userUserName: testingUserData.username,
        userID: testingUserFirestoreId,
        centauriPoints: 10,
        userRank: 1,
      );

      final rankingElementDetail2 = RankingElementDetails(
        userDisplayName: testingUserData.displayName,
        userUserName: testingUserData.username,
        userID: testingUserFirestoreId,
        centauriPoints: 10,
        userRank: 1,
      );

      expect(rankingElementDetail1, rankingElementDetail2);
    });

    test("!= userDisplayName", () {
      final rankingElementDetail1 = RankingElementDetails(
        userDisplayName: testingUserData.displayName,
        userUserName: testingUserData.username,
        userID: testingUserFirestoreId,
        centauriPoints: 10,
        userRank: 1,
      );

      final rankingElementDetail2 = RankingElementDetails(
        userDisplayName: "${testingUserData.displayName}_2",
        userUserName: testingUserData.username,
        userID: testingUserFirestoreId,
        centauriPoints: 10,
        userRank: 1,
      );

      expect(rankingElementDetail1, isNot(equals(rankingElementDetail2)));
    });

    test("!= centauriPoints", () {
      final rankingElementDetail1 = RankingElementDetails(
        userDisplayName: testingUserData.displayName,
        userUserName: testingUserData.username,
        userID: testingUserFirestoreId,
        centauriPoints: 10,
        userRank: 1,
      );

      final rankingElementDetail2 = RankingElementDetails(
        userDisplayName: testingUserData.displayName,
        userUserName: testingUserData.username,
        userID: testingUserFirestoreId,
        centauriPoints: 12,
        userRank: 1,
      );

      expect(rankingElementDetail1, isNot(equals(rankingElementDetail2)));
    });

    test("!= userRank", () {
      final rankingElementDetail1 = RankingElementDetails(
        userDisplayName: testingUserData.displayName,
        userUserName: testingUserData.username,
        userID: testingUserFirestoreId,
        centauriPoints: 10,
        userRank: 1,
      );

      final rankingElementDetail2 = RankingElementDetails(
        userDisplayName: testingUserData.displayName,
        userUserName: testingUserData.username,
        userID: testingUserFirestoreId,
        centauriPoints: 10,
        userRank: 2,
      );

      expect(rankingElementDetail1, isNot(equals(rankingElementDetail2)));
    });

    test("!= userID", () {
      final rankingElementDetail1 = RankingElementDetails(
        userDisplayName: testingUserData.displayName,
        userUserName: testingUserData.username,
        userID: testingUserFirestoreId,
        centauriPoints: 10,
        userRank: 1,
      );

      final rankingElementDetail2 = RankingElementDetails(
        userDisplayName: testingUserData.displayName,
        userUserName: testingUserData.username,
        userID: const UserIdFirestore(value: "not_the_same_uid"),
        centauriPoints: 10,
        userRank: 1,
      );

      expect(rankingElementDetail1, isNot(equals(rankingElementDetail2)));
    });
  });
}
