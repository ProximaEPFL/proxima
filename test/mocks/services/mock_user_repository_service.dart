import "package:cloud_firestore/cloud_firestore.dart";
import "package:mockito/mockito.dart";
import "package:proxima/models/database/user/user_data.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/services/database/user_repository_service.dart";

class MockUserRepositoryService extends Mock implements UserRepositoryService {
  /// Not a coherent representation of a [UserFirestore]
  /// This is just here as a placeholder value that will be overridden in the tests
  final _emptyFirestoreUser = UserFirestore(
    data: UserData(
      displayName: "",
      username: "",
      joinTime: Timestamp.fromMillisecondsSinceEpoch(0),
      centauriPoints: 0,
    ),
    uid: const UserIdFirestore(value: ""),
  );

  @override
  Future<UserFirestore> getUser(UserIdFirestore? uid) {
    return super.noSuchMethod(
      Invocation.method(#getUser, [uid]),
      returnValue: Future.value(_emptyFirestoreUser),
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
