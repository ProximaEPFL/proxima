import "package:cloud_firestore/cloud_firestore.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/challenge/challenge_data.dart";
import "package:proxima/models/database/challenge/challenge_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/services/database/firestore_service.dart";

class ChallengeRepositoryService {
  final FirebaseFirestore _firestore;

  static const int _maxActiveChallenges = 3;

  static PostIdFirestore _fakePostProvider() =>
      const PostIdFirestore(value: "fake"); // TODO fix

  ChallengeRepositoryService({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  Future<List<ChallengeFirestore>> getChallenges(UserIdFirestore uid) async {
    final userDocRef =
        _firestore.collection(UserFirestore.collectionName).doc(uid.value);

    return _getChallenges(userDocRef, _fakePostProvider);
  }

  Future<List<ChallengeFirestore>> _getChallenges(
    DocumentReference parentRef,
    PostIdFirestore? Function() postProvider,
  ) async {
    final challengesCollectionRef =
        parentRef.collection(ChallengeFirestore.subCollectionName);
    final pastChallengesCollectionRef = parentRef
        .collection(ChallengeFirestore.pastChallengesSubCollectionName);

    return _firestore.runTransaction((transaction) async {
      // TODO not sure if this is actually atomic
      // move expired challenges to past challenges
      final challengesSnap = await challengesCollectionRef.get();
      final pastChallengesSnap = await pastChallengesCollectionRef.get();
      final pastPostIds = pastChallengesSnap.docs.map((doc) => doc.id).toSet();

      final activeChallenges = List.empty();

      for (final challengeSnap in challengesSnap.docs) {
        final challenge = ChallengeFirestore.fromDb(challengeSnap);
        if (challenge.data.isExpired) {
          await pastChallengesCollectionRef
              .doc(challengeSnap.id)
              .set(challengeSnap.data());
          await challengesCollectionRef.doc(challengeSnap.id).delete();
        } else {
          activeChallenges.add(challenge);
        }
      }

      final now = DateTime.now();
      final endOfDay = DateTime(now.year, now.month, now.day + 1);

      while (activeChallenges.length < _maxActiveChallenges) {
        final post = postProvider();
        if (post == null) {
          break;
        }

        if (pastPostIds.contains(post.value)) {
          continue;
        }

        final newChallenge = ChallengeFirestore(
          postId: post,
          data: ChallengeData(
            isCompleted: false,
            expiresOn: Timestamp.fromDate(endOfDay),
          ),
        );

        await challengesCollectionRef.add(newChallenge.data.toDbData());
        activeChallenges.add(newChallenge);
      }

      activeChallenges;
    });
  }
}

final challengeRepositoryServiceProvider = Provider<ChallengeRepositoryService>(
  (ref) {
    return ChallengeRepositoryService(firestore: ref.watch(firestoreProvider));
  },
);
