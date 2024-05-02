import "package:cloud_firestore/cloud_firestore.dart";
import "package:proxima/models/database/challenge/challenge_data.dart";

class ChallengeGenerator {
  ChallengeGenerator._();

  /// Generates a challenge (using mock data).
  /// It expires in [expirationDelay] (i.e., it expires at `DateTime.now() + expirationDelay`),
  /// and the generated challenge may be completed or not, depending on [isCompleted].
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
