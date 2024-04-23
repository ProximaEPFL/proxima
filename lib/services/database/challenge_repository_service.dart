import "dart:core";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/challenge/challenge_data.dart";
import "package:proxima/models/database/challenge/challenge_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/services/database/firestore_service.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/services/geolocation_service.dart";

class ChallengeRepositoryService {
  final FirebaseFirestore _firestore;
  final PostRepositoryService _postRepositoryService;
  final GeoLocationService _geoLocationService;

  static const int _maxActiveChallenges = 3;
  static const double _challengeRadius = 2000;

  ChallengeRepositoryService({
    required FirebaseFirestore firestore,
    required PostRepositoryService postRepositoryService,
    required GeoLocationService geoLocationService,
  })
      : _firestore = firestore,
        _postRepositoryService = postRepositoryService,
        _geoLocationService = geoLocationService;

  Future<List<ChallengeFirestore>> getChallenges(UserIdFirestore uid) async {
    final userDocRef =
    _firestore.collection(UserFirestore.collectionName).doc(uid.value);

    return _getChallenges(userDocRef, await nearbyUnsortedProvider());
  }

  Future<List<ChallengeFirestore>> _getChallenges(DocumentReference parentRef,
      Iterator<PostIdFirestore> postIt,) async {
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

      final List<ChallengeFirestore> activeChallenges = List.empty();

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

      while (
      activeChallenges.length < _maxActiveChallenges && postIt.moveNext()) {
        final post = postIt.current;

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

      return activeChallenges;
    });
  }

  Future<Iterator<PostIdFirestore>> nearbyUnsortedProvider() async {
    final position = await _geoLocationService.getCurrentPosition();
    final possiblePosts = await _postRepositoryService.getNearPosts(
      position, _challengeRadius,);
    final possibleIds = possiblePosts.map((e) => e.id);
    return possibleIds.iterator;
  }
}

final challengeRepositoryServiceProvider = Provider<ChallengeRepositoryService>(
      (ref) {
    return ChallengeRepositoryService(
      firestore: ref.watch(firestoreProvider),
      postRepositoryService: ref.watch(postRepositoryProvider),
      geoLocationService: ref.watch(geoLocationServiceProvider),
    );
  },
);
