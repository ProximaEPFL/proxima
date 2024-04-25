import "package:cloud_firestore/cloud_firestore.dart";
import "package:proxima/models/database/challenge/challenge_data.dart";

class ChallengeGenerator {
  ChallengeGenerator._();

  /// Generates a challenge
  /// by default, the challenge is not completed and expires now
  /// [isCompleted] whether the challenge is completed
  /// [expirationDelay] the delay until the challenge expires. The challenge will expire at DateTime.now() + expirationDelay
  static ChallengeData generate([
    bool isCompleted = false,
    Duration expirationDelay = Duration.zero,
  ]) {
    final expiration = DateTime.now().add(expirationDelay);
    return ChallengeData(
      isCompleted: isCompleted,
      expiresOn: Timestamp.fromDate(expiration),
    );
  }
}
