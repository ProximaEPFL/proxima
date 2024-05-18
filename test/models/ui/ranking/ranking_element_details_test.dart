import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/ui/ranking/ranking_element_details.dart";

import "../../../mocks/data/firestore_user.dart";

void main() {
  group("hash and == works", () {
    test("hash", () {
      final rankingElementDetail = RankingElementDetails(
        userDisplayName: testingUserData.displayName,
        centauriPoints: 10,
        userRank: 1,
      );

      final expectedHash = Object.hash(
        rankingElementDetail.userDisplayName,
        rankingElementDetail.centauriPoints,
        rankingElementDetail.userRank,
      );

      final actualHash = rankingElementDetail.hashCode;

      expect(actualHash, expectedHash);
    });

    test("==", () {
      final rankingElementDetail1 = RankingElementDetails(
        userDisplayName: testingUserData.displayName,
        centauriPoints: 10,
        userRank: 1,
      );

      final rankingElementDetail2 = RankingElementDetails(
        userDisplayName: testingUserData.displayName,
        centauriPoints: 10,
        userRank: 1,
      );

      expect(rankingElementDetail1 == rankingElementDetail2, isTrue);
    });

    test("!= userDisplayName", () {
      final rankingElementDetail1 = RankingElementDetails(
        userDisplayName: testingUserData.displayName,
        centauriPoints: 10,
        userRank: 1,
      );

      final rankingElementDetail2 = RankingElementDetails(
        userDisplayName: "${testingUserData.displayName}_2",
        centauriPoints: 10,
        userRank: 1,
      );

      expect(rankingElementDetail1 == rankingElementDetail2, isFalse);
    });

    test("!= centauriPoints", () {
      final rankingElementDetail1 = RankingElementDetails(
        userDisplayName: testingUserData.displayName,
        centauriPoints: 10,
        userRank: 1,
      );

      final rankingElementDetail2 = RankingElementDetails(
        userDisplayName: testingUserData.displayName,
        centauriPoints: 12,
        userRank: 1,
      );

      expect(rankingElementDetail1 == rankingElementDetail2, isFalse);
    });

    test("!= userRank", () {
      final rankingElementDetail1 = RankingElementDetails(
        userDisplayName: testingUserData.displayName,
        centauriPoints: 10,
        userRank: 1,
      );

      final rankingElementDetail2 = RankingElementDetails(
        userDisplayName: testingUserData.displayName,
        centauriPoints: 10,
        userRank: 2,
      );

      expect(rankingElementDetail1 == rankingElementDetail2, isFalse);
    });
  });
}
