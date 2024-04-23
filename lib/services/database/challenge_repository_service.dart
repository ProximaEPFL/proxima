import "package:cloud_firestore/cloud_firestore.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/challenge/challenge_firestore.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/services/database/firestore_service.dart";

class ChallengeRepositoryService {
  final FirebaseFirestore _firestore;

  ChallengeRepositoryService({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  Future<List<ChallengeFirestore>> getChallenges(UserIdFirestore uid) async {
    final userDocRef =
        _firestore.collection(UserFirestore.collectionName).doc(uid.value);

    return _getChallenges(userDocRef);
  }

  Future<List<ChallengeFirestore>> _getChallenges(
    DocumentReference parentRef,
  ) async {
    final challengesCollectionRef =
        parentRef.collection(ChallengeFirestore.subCollectionName);

    final query = await challengesCollectionRef.get();
    return query.docs.map((doc) => ChallengeFirestore.fromDb(doc)).toList();
  }

  Future<void> _refreshChallenges() {}
}

final challengeRepositoryServiceProvider = Provider<ChallengeRepositoryService>(
  (ref) {
    return ChallengeRepositoryService(firestore: ref.watch(firestoreProvider));
  },
);
