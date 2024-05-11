import "package:flutter/foundation.dart";

/// This class was hard to design. We considered multiple possible implementations,
/// and decided to use this one. If we add a parameter requiring to double the number of
/// constructors once more, it should be changed. Here are all the possibilities:
/// 1) Use one constructor per possibility, storing unused parameter as null internally (it is
///    the possibility we chose here).
/// 2) Use a single constructor, asking the developer instanciating it to set the correct
///    parameters to null (a null distance to finish the challenge, for instance).
/// 3) Use a single constructor, but with additional boolean parameters to specify if the
///    class is a group challenge or if it is finished. This requires asserts to check that
///    the parameters are consistent (distance must be null if and only if isFinished is true).
/// 4) Use a single constructor taking a title and a reward, and add methods .notFinished(distance)
///    and .notGroup(timeLeft) to create new instances with the new parameters (in a factory-pattern way).
@immutable
class ChallengeDetails {
  final String title;
  final int? distance;
  final int? timeLeft;
  final int reward;

  /// Creates a [ChallengeDetails] with the given parameters. The [title] is the
  /// post's title, the [distance] is the distance to the challenge in meters, the [timeLeft]
  /// is the time left to complete the challenge in hours, and the [reward] is the reward
  /// for completing the challenge.
  const ChallengeDetails.solo({
    required this.title,
    required int this.distance,
    required int this.timeLeft,
    required this.reward,
  });

  const ChallengeDetails.group({
    required this.title,
    required int this.distance,
    required this.reward,
  }) : timeLeft = null;

  const ChallengeDetails.soloFinished({
    required this.title,
    required int this.timeLeft,
    required this.reward,
  }) : distance = null;

  const ChallengeDetails.groupFinished({
    required this.title,
    required this.reward,
  })  : distance = null,
        timeLeft = null;

  bool get isFinished => distance == null;
  bool get isGroupChallenge => timeLeft == null;

  @override
  bool operator ==(Object other) {
    return other is ChallengeDetails &&
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
