import "dart:core";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:geoflutterfire_plus/geoflutterfire_plus.dart";
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
    parentRef
        .collection(ChallengeFirestore.subCollectionName)
        .doc(pid.value)
        .update({
      ChallengeData.isCompletedField: true,
    });
  }

  /// Returns the active challenges of the user with id [uid] that is located at [pos]
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
    final pastChallengesSnap = await pastChallengesCollectionRef.get();

    final pastPostIds = pastChallengesSnap.docs
        .map((doc) => PostIdFirestore(value: doc.id))
        .toSet();

    final List<ChallengeFirestore> activeChallenges =
        List.empty(growable: true);

    for (final challengeSnap in challengesSnap.docs) {
      final challenge = ChallengeFirestore.fromDb(challengeSnap);
      if (challenge.data.isExpired ||
          !await _postRepositoryService.postExists(challenge.postId)) {
        _deleteChallenge(challengeSnap, parentRef);
        pastPostIds.add(challenge.postId);
      } else {
        activeChallenges.add(challenge);
      }
    }

    final now = DateTime.now();
    final sum = now.add(maxChallengeDuration);
    final expiresOn = DateTime(
      sum.year,
      sum.month,
      sum.day,
    ); // truncates to the day

    final possiblePosts = await inRangeUnsortedPosts(pos);
    final postIt = possiblePosts.iterator;
    final activePostIds = activeChallenges.map((e) => e.postId).toSet();
    while (activeChallenges.length < maxActiveChallenges && postIt.moveNext()) {
      final post = postIt.current;

      if (pastPostIds.contains(post) || activePostIds.contains(post)) {
        continue;
      }

      final newChallenge = ChallengeFirestore(
        postId: post,
        data: ChallengeData(
          isCompleted: false,
          expiresOn: Timestamp.fromDate(expiresOn),
        ),
      );

      await challengesCollectionRef
          .doc(post.value)
          .set(newChallenge.data.toDbData());
      activeChallenges.add(newChallenge);
      activePostIds.add(post);
    }

    return activeChallenges;
  }

  /// moves the challenge with id [pid] from the active challenges to the past challenges
  Future<void> _deleteChallenge(
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

  Future<Iterable<PostIdFirestore>> inRangeUnsortedPosts(GeoPoint pos) async {
    final geoFirePosition = GeoFirePoint(pos);
    Iterable<PostFirestore> possiblePosts =
        await _postRepositoryService.getNearPosts(
      pos,
      maxChallengeRadius,
    );

    possiblePosts = possiblePosts.where(
      (post) =>
          geoFirePosition.distanceBetweenInKm(
            geopoint: post.location.geoPoint,
          ) >
          minChallengeRadius,
    );

    return possiblePosts.map((e) => e.id);
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
