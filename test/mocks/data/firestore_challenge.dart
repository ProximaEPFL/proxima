import "package:cloud_firestore/cloud_firestore.dart";
import "package:proxima/models/database/challenge/challenge_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";

import "challenge_data.dart";

class FirestoreChallengeGenerator {
  int _id = 0;

  ChallengeFirestore generate(bool done, Duration extra) {
    final data = ChallengeGenerator.generate(done, extra);
    final id = PostIdFirestore(value: (_id++).toString());
    return ChallengeFirestore(postId: id, data: data);
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
