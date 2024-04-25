import "dart:core";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/challenge/challenge_data.dart";
import "package:proxima/models/database/challenge/challenge_firestore.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/services/database/firestore_service.dart";
import "package:proxima/services/database/post_repository_service.dart";

/// This repository service is responsible for handling the challenges
class ChallengeRepositoryService {
  final FirebaseFirestore _firestore;
  final PostRepositoryService _postRepositoryService;

  static const int maxActiveChallenges = 3;
  static const double maxChallengeRadius = 3; // in km
  static const double minChallengeRadius = 0.5;
  static const maxChallengeDuration = Duration(days: 1);

  /// Creates a new challenge repository service
  /// with the given [firestore] and [postRepositoryService]
  ChallengeRepositoryService({
    required FirebaseFirestore firestore,
    required PostRepositoryService postRepositoryService,
  })  : _firestore = firestore,
        _postRepositoryService = postRepositoryService;

  /// Completes the challenge of the user with id [uid] on the post with id [pid]
  Future<void> completeChallenge(
    UserIdFirestore uid,
    PostIdFirestore pid,
  ) async {
    final userDocRef =
        _firestore.collection(UserFirestore.collectionName).doc(uid.value);
    await _completeChallenge(userDocRef, pid);
  }

  Future<void> _completeChallenge(
    DocumentReference parentRef,
    PostIdFirestore pid,
  ) async {
    await parentRef
        .collection(ChallengeFirestore.subCollectionName)
        .doc(pid.value)
        .update({
      ChallengeData.isCompletedField: true,
    });
  }

  /// Returns the active challenges of the user with id [uid] who is located at [pos].
  /// If challenges are expired or missing, they are replaced by new challenges in the
  /// database, and then returned. This therefore always ensure this method will return
  /// challenges, all up-to-date; trying its best to find [maxActiveChallenges] (if
  /// enough exist close enough).
  /// Warning: This method is NOT atomic, and therefore not thread-safe. We suppose here
  /// no malicious user will try to load the challenge page on two different devices at
  /// the same time. In fact, even if this happens, this should not be a big problem.
  Future<List<ChallengeFirestore>> getChallenges(
    UserIdFirestore uid,
    GeoPoint pos,
  ) async {
    final userDocRef =
        _firestore.collection(UserFirestore.collectionName).doc(uid.value);

    return _getChallenges(userDocRef, pos);
  }

  Future<List<ChallengeFirestore>> _getChallenges(
    DocumentReference parentRef,
    GeoPoint pos,
  ) async {
    final challengesCollectionRef =
        parentRef.collection(ChallengeFirestore.subCollectionName);
    final pastChallengesCollectionRef = parentRef
        .collection(ChallengeFirestore.pastChallengesSubCollectionName);

    final challengesSnap = await challengesCollectionRef.get();

    final Set<PostIdFirestore> justExpired = {};
    final List<ChallengeFirestore> activeChallenges =
        List.empty(growable: true);

    for (final challengeSnap in challengesSnap.docs) {
      final challenge = ChallengeFirestore.fromDb(challengeSnap);
      if (challenge.data.isExpired ||
          !await _postRepositoryService.postExists(challenge.postId)) {
        await _moveToPastChallenge(challengeSnap, parentRef);
        justExpired.add(challenge.postId);
      } else {
        activeChallenges.add(challenge);
      }
    }

    if (activeChallenges.length < maxActiveChallenges) {
      final now = DateTime.now();
      final sum = now.add(maxChallengeDuration);
      final expiresOn = DateTime(
        sum.year,
        sum.month,
        sum.day,
      ); // truncates to the day

      Iterable<PostIdFirestore> possiblePosts =
          await _inRangeUnsortedPosts(pos);
      possiblePosts =
          possiblePosts.where((post) => !justExpired.contains(post));

      final alreadyDonePostsSnap = await pastChallengesCollectionRef
          .where(FieldPath.documentId, whereIn: possiblePosts)
          .get();

      final alreadyDonePosts = alreadyDonePostsSnap.docs
          .map((post) => PostIdFirestore(value: post.id))
          .toSet();

      final postIt = possiblePosts.iterator;
      final activePostIds =
          activeChallenges.map((challenge) => challenge.postId).toSet();
      while (
          activeChallenges.length < maxActiveChallenges && postIt.moveNext()) {
        final post = postIt.current;

        if (alreadyDonePosts.contains(post) || activePostIds.contains(post)) {
          continue;
        }

        final newChallenge = ChallengeFirestore(
          postId: post,
          data: ChallengeData(
            isCompleted: false,
            expiresOn: Timestamp.fromDate(expiresOn),
          ),
        );

        await _addChallenge(newChallenge, parentRef);
        activeChallenges.add(newChallenge);
        activePostIds.add(post);
      }
    }

    return activeChallenges;
  }

  Future<void> _addChallenge(
    ChallengeFirestore challenge,
    DocumentReference parentRef,
  ) async {
    await parentRef
        .collection(ChallengeFirestore.subCollectionName)
        .doc(challenge.postId.value)
        .set(challenge.data.toDbData());
  }

  /// moves the challenge with id [pid] from the active challenges to the past challenges
  Future<void> _moveToPastChallenge(
    DocumentSnapshot<Map<String, dynamic>> challengeSnap,
    DocumentReference parentRef,
  ) async {
    final batch = _firestore.batch();
    batch.set(
      parentRef
          .collection(ChallengeFirestore.pastChallengesSubCollectionName)
          .doc(challengeSnap.id),
      challengeSnap.data()!,
    );
    batch.delete(challengeSnap.reference);
    await batch.commit();
  }

  Future<Iterable<PostIdFirestore>> _inRangeUnsortedPosts(GeoPoint pos) async {
    Iterable<PostFirestore> possiblePosts =
        await _postRepositoryService.getNearPosts(
      pos,
      maxChallengeRadius,
      minChallengeRadius,
    );

    return possiblePosts.map((post) => post.id);
  }
}

final challengeRepositoryServiceProvider = Provider<ChallengeRepositoryService>(
  (ref) {
    return ChallengeRepositoryService(
      firestore: ref.watch(firestoreProvider),
      postRepositoryService: ref.watch(postRepositoryProvider),
    );
  },
);
