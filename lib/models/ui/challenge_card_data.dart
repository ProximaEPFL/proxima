import "package:flutter/foundation.dart";

@immutable
class ChallengeCardData {
  final String title;
  final int? distance;
  final int? timeLeft;
  final int reward;

  /// Creates a [ChallengeCardData] with the given parameters. The [title] is the
  /// post's title, the [distance] is the distance to the challenge in meters, the [timeLeft]
  /// is the time left to complete the challenge in hours, and the [reward] is the reward
  /// for completing the challenge.
  /// If the [distance] is `null`, the challenge is finished. If the [timeLeft]
  /// is `null`, the challenge is a group challenge.
  const ChallengeCardData({
    required this.title,
    required this.distance,
    required this.timeLeft,
    required this.reward,
  });

  bool get isFinished => distance == null;
  bool get isGroupChallenge => timeLeft == null;

  @override
  bool operator ==(Object other) {
    return other is ChallengeCardData &&
        other.title == title &&
        other.distance == distance &&
        other.timeLeft == timeLeft &&
        other.reward == reward;
  }

  @override
  int get hashCode {
    return Object.hash(title, distance, timeLeft, reward);
  }
}
