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

class ChallengeRepositoryService {
  final FirebaseFirestore _firestore;
  final PostRepositoryService _postRepositoryService;

  static const int _maxActiveChallenges = 3;
  static const double _maxChallengeRadius = 3; // in km
  static const double _minChallengeRadius = 0.5;
  static const maxChallengeDuration = Duration(days: 1);

  ChallengeRepositoryService({
    required FirebaseFirestore firestore,
    required PostRepositoryService postRepositoryService,
  })  : _firestore = firestore,
        _postRepositoryService = postRepositoryService;

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

    return _firestore.runTransaction((transaction) async {
      // TODO not sure if this is actually atomic
      // move expired challenges to past challenges
      final challengesSnap = await challengesCollectionRef.get();
      final pastChallengesSnap = await pastChallengesCollectionRef.get();
      final pastPostIds = pastChallengesSnap.docs
          .map((doc) => PostIdFirestore(value: doc.id))
          .toSet();

      final List<ChallengeFirestore> activeChallenges =
          List.empty(growable: true);

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
      final sum = now.add(maxChallengeDuration);
      final expiresOn = DateTime(
        sum.year,
        sum.month,
        sum.day,
      ); // truncates to the day

      final possiblePosts = await inRangeUnsortedPosts(pos);
      final postIt = possiblePosts.iterator;
      final activePostIds = activeChallenges.map((e) => e.postId).toSet();
      while (
          activeChallenges.length < _maxActiveChallenges && postIt.moveNext()) {
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
    });
  }

  Future<Iterable<PostIdFirestore>> inRangeUnsortedPosts(GeoPoint pos) async {
    final geoFirePosition = GeoFirePoint(pos);
    List<PostFirestore> possiblePosts =
        await _postRepositoryService.getNearPosts(
      pos,
      _maxChallengeRadius,
    );

    possiblePosts.where(
      (post) =>
          geoFirePosition.distanceBetweenInKm(
            geopoint: post.location.geoPoint,
          ) >
          _minChallengeRadius,
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
