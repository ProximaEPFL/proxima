import "package:cloud_firestore/cloud_firestore.dart";
import "package:proxima/models/database/challenge/challenge_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";

import "challenge_data.dart";

class FirestoreChallengeGenerator {
  int _id = 0;

  ChallengeFirestore generateChallenge(bool done, Duration extra) {
    final data = ChallengeGenerator.generate(done, extra);
    final id = PostIdFirestore(value: (_id++).toString());
    return ChallengeFirestore(postId: id, data: data);
  }

  List<ChallengeFirestore> generateChallenges(
    int count,
    bool done,
    Duration extra,
  ) {
    // The index is ignored since, anyway, `_id` will be increased every
    // time, yielding different challenges.
    return List.generate(count, (_) => generateChallenge(done, extra));
  }

  /// Generates a challenge linked to some [postId]. Its data is defined by
  /// [ChallengeGenerator.generate]. See this function for documentation of
  /// the other parameters.
  static ChallengeFirestore generateFromPostId(
    PostIdFirestore postId, [
    bool isCompleted = false,
    Duration expirationDelay = Duration.zero,
  ]) {
    return ChallengeFirestore(
      postId: postId,
      data: ChallengeGenerator.generate(
        isCompleted,
        expirationDelay,
      ),
    );
  }
}

Future<void> setChallenge(
  FirebaseFirestore firestore,
  ChallengeFirestore challenge,
  UserIdFirestore uid,
) async {
  final challengeRef = firestore
      .collection(UserFirestore.collectionName)
      .doc(uid.value)
      .collection(ChallengeFirestore.subCollectionName)
      .doc(challenge.postId.value);

  await challengeRef.set(challenge.data.toDbData());
}

Future<void> setChallenges(
  FirebaseFirestore firestore,
  List<ChallengeFirestore> challenges,
  UserIdFirestore uid,
) async {
  for (final challenge in challenges) {
    await setChallenge(firestore, challenge, uid);
  }
}
