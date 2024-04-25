import "package:proxima/models/ui/challenge_card_data.dart";

// All values are purposely different to test the UI more easily
const mockChallengeList = [
  ChallengeCardData.solo(
    title: "I hate UNIL, here's why",
    distance: 700,
    timeLeft: 27,
    reward: 250,
  ),
  ChallengeCardData.solo(
    title:
        "John fell here lmaoooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo",
    distance: 3200,
    timeLeft: 28,
    reward: 400,
  ),
  ChallengeCardData.group(
    title: "I'm moving out",
    distance: 4000,
    reward: 350,
  ),
  ChallengeCardData.soloFinished(
    title: "What a view!",
    timeLeft: 29,
    reward: 200,
  ),
];
