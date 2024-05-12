import "package:proxima/models/ui/challenge_details.dart";

// All values are purposely different to test the UI more easily

const mockChallengeList = [
  ChallengeDetails.solo(
    title: "I hate UNIL, here's why",
    distance: 700,
    timeLeft: 27,
    reward: 250,
  ),
  ChallengeDetails.solo(
    title:
        "John fell here lmaoooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo",
    distance: 3200,
    timeLeft: 28,
    reward: 400,
  ),
  ChallengeDetails.group(
    title: "I'm moving out",
    distance: 4000,
    reward: 350,
  ),
  ChallengeDetails.soloFinished(
    title: "What a view!",
    timeLeft: 29,
    reward: 200,
  ),
  ChallengeDetails.groupFinished(
    title: "I saw a bird here once",
    reward: 50,
  ),
];
