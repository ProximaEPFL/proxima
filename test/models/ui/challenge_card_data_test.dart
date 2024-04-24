import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/ui/challenge_card_data.dart";

void main() {
  group("Challenge card data testing", () {
    test("hash overrides correctly", () {
      const challengeCard = ChallengeCardData(
        title: "title",
        distance: 50,
        timeLeft: null,
        reward: 100,
      );

      final expectedHash = Object.hash(
        challengeCard.title,
        challengeCard.distance,
        challengeCard.timeLeft,
        challengeCard.reward,
      );

      final actualHash = challengeCard.hashCode;

      expect(actualHash, expectedHash);
    });

    test("equality overrides correctly", () {
      const challengeCardData = ChallengeCardData(
        title: "title",
        distance: 50,
        timeLeft: null,
        reward: 100,
      );
      const challengeCardDataCopy = ChallengeCardData(
        title: "title",
        distance: 50,
        timeLeft: null,
        reward: 100,
      );

      expect(challengeCardData, challengeCardDataCopy);
    });
  });
}
