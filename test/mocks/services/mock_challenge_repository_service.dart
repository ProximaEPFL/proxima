import "package:cloud_firestore/cloud_firestore.dart";
import "package:mockito/mockito.dart";
import "package:proxima/models/database/challenge/challenge_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";

import "package:proxima/services/database/challenge_repository_service.dart";

class MockChallengeRepositoryService extends Mock
    implements ChallengeRepositoryService {
  @override
  Future<bool> completeChallenge(
    UserIdFirestore uid,
    PostIdFirestore pid,
  ) async {
    return super.noSuchMethod(
      Invocation.method(#completeChallenge, [uid, pid]),
      returnValue: Future.value(true),
    );
  }

  @override
  Future<List<ChallengeFirestore>> getChallenges(
    UserIdFirestore uid,
    GeoPoint pos,
  ) async {
    return super.noSuchMethod(
      Invocation.method(#getChallenges, [uid, pos]),
      returnValue: Future.value(<ChallengeFirestore>[]),
    );
  }
}
