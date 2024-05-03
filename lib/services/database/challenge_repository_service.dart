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
import "package:proxima/services/database/user_repository_service.dart";

/// This repository service is responsible for handling the challenges
class ChallengeRepositoryService {
  final FirebaseFirestore _firestore;
  final PostRepositoryService _postRepositoryService;
  final UserRepositoryService _userRepositoryService;

  static const int maxActiveChallenges = 3;
  static const double maxChallengeRadius = 3; // in km
  static const double minChallengeRadius = 0.5;
  static const maxChallengeDuration = Duration(days: 1);
  static const soloChallengeReward = 500;

  /// Creates a new challenge repository service
  /// with the given [firestore] and [postRepositoryService]
  ChallengeRepositoryService({
    required FirebaseFirestore firestore,
    required PostRepositoryService postRepositoryService,
    required UserRepositoryService userRepositoryService,
  })  : _firestore = firestore,
        _postRepositoryService = postRepositoryService,
        _userRepositoryService = userRepositoryService;

  CollectionReference<Map<String, dynamic>> _activeChallengesRef(
    DocumentReference parentRef,
  ) {
    return parentRef.collection(ChallengeFirestore.subCollectionName);
  }

  CollectionReference<Map<String, dynamic>> _pastChallengesRef(
    DocumentReference parentRef,
  ) {
    return parentRef
        .collection(ChallengeFirestore.pastChallengesSubCollectionName);
  }

  /// Completes the challenge of the user with id [uid] on the post with id [pid].
  /// Returns true if the challenge is valid and was completed, and false otherwise.
  /// The challenge could be invalid if the post does not correspond to a current
  /// challenge, if the challenge was already completed or if the challenge expired.
  Future<bool> completeChallenge(
    UserIdFirestore uid,
    PostIdFirestore pid,
  ) async {
    final userDocRef =
        _firestore.collection(UserFirestore.collectionName).doc(uid.value);
    final challengeSnap =
        await _activeChallengesRef(userDocRef).doc(pid.value).get();

    if (!challengeSnap.exists) {
      return false;
    }

    final challengeData = ChallengeData.fromDb(challengeSnap.data()!);
    if (challengeData.isCompleted || challengeData.isExpired) {
      return false;
    }

    await _activeChallengesRef(userDocRef).doc(pid.value).update({
      ChallengeData.isCompletedField: true,
    });
    await _userRepositoryService.addPoints(uid, soloChallengeReward);
    return true;
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
    final List<ChallengeFirestore> activeChallenges =
        List.empty(growable: true);

    await _removeOldChallenges(userDocRef, activeChallenges);

    if (activeChallenges.length < maxActiveChallenges) {
      await _generateNewChallenges(
        activeChallenges,
        pos,
        userDocRef,
        uid,
      );
    }

    return activeChallenges;
  }

  /// Adds active challenges to [activeChallenges]. Removes expired challenges
  /// from the database.
  Future<void> _removeOldChallenges(
    DocumentReference parentRef,
    List<ChallengeFirestore> activeChallenges,
  ) async {
    final challengesCollectionRef = _activeChallengesRef(parentRef);
    final challengesSnap = await challengesCollectionRef.get();

    for (final challengeSnap in challengesSnap.docs) {
      final challenge = ChallengeFirestore.fromDb(challengeSnap);
      if (challenge.data.isExpired ||
          !await _postRepositoryService.postExists(challenge.postId)) {
        await _moveToPastChallenge(challengeSnap, parentRef);
      } else {
        activeChallenges.add(challenge);
      }
    }
  }

  /// Generates new challenges and puts them in [activeChallenges]
  Future<void> _generateNewChallenges(
    List<ChallengeFirestore> activeChallenges,
    GeoPoint pos,
    DocumentReference parentRef,
    UserIdFirestore excludedUser,
  ) async {
    final now = DateTime.now();
    final sum = now.add(maxChallengeDuration);
    final expiresOn = DateTime(
      sum.year,
      sum.month,
      sum.day,
    ); // truncates to the day

    final Iterable<PostIdFirestore> possiblePosts =
        await _inRangeUnsortedPosts(pos, excludedUser);

    // The whereIn argument of the where method crashed
    // if the query is empty for the real firestore. This
    // cannot be tested with the mock firestore.
    if (possiblePosts.isEmpty) return;

    final Iterable<String> possiblePostsStringIds =
        possiblePosts.map((post) => post.value);

    final pastChallengesCollectionRef = _pastChallengesRef(parentRef);
    final alreadyDonePostsSnap = await pastChallengesCollectionRef
        .where(FieldPath.documentId, whereIn: possiblePostsStringIds)
        .get();

    final alreadyDonePosts = alreadyDonePostsSnap.docs
        .map((post) => PostIdFirestore(value: post.id))
        .toSet();

    final postIt = possiblePosts.iterator;
    final activePostIds =
        activeChallenges.map((challenge) => challenge.postId).toSet();
    while (activeChallenges.length < maxActiveChallenges && postIt.moveNext()) {
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

  Future<void> _addChallenge(
    ChallengeFirestore challenge,
    DocumentReference parentRef,
  ) async {
    await _activeChallengesRef(parentRef)
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
      _pastChallengesRef(parentRef).doc(challengeSnap.id),
      challengeSnap.data()!,
    );
    batch.delete(challengeSnap.reference);
    await batch.commit();
  }

  Future<Iterable<PostIdFirestore>> _inRangeUnsortedPosts(
    GeoPoint pos,
    UserIdFirestore excludedUser,
  ) async {
    Iterable<PostFirestore> possiblePosts =
        await _postRepositoryService.getNearPosts(
      pos,
      maxChallengeRadius,
      minChallengeRadius,
    );

    return possiblePosts
        .where((post) => post.data.ownerId != excludedUser)
        .map((post) => post.id);
  }
}

final challengeRepositoryServiceProvider = Provider<ChallengeRepositoryService>(
  (ref) {
    return ChallengeRepositoryService(
      firestore: ref.watch(firestoreProvider),
      postRepositoryService: ref.watch(postRepositoryProvider),
      userRepositoryService: ref.watch(userRepositoryProvider),
    );
  },
);
