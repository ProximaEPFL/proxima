import "package:mockito/mockito.dart";
import "package:proxima/models/database/user/user_data.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/services/database/user_repository_service.dart";

import "../data/mock_firestore_user.dart";

class MockUserRepositoryService extends Mock implements UserRepositoryService {
  @override
  Future<UserFirestore> getUser(UserIdFirestore? uid) {
    return super.noSuchMethod(
      Invocation.method(#getUser, [uid]),
      returnValue: Future.value(mockEmptyFirestoreUser),
    );
  }

  @override
  Future<void> setUser(UserIdFirestore? uid, UserData? userData) {
    return super.noSuchMethod(
      Invocation.method(#setUser, [uid, userData]),
      returnValue: Future.value(),
    );
  }

  @override
  Future<bool> doesUserExist(UserIdFirestore? uid) {
    return super.noSuchMethod(
      Invocation.method(#doesUserExist, [uid]),
      returnValue: Future.value(false),
    );
  }
}
