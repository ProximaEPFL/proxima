import "dart:async";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/user/user_data.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/services/database/firestore_service.dart";

class UserRepositoryService {
  final CollectionReference _collectionRef;

  UserRepositoryService({
    required FirebaseFirestore firestore,
  }) : _collectionRef = firestore.collection(UserFirestore.collectionName);

  Future<UserFirestore> getUser(UserIdFirestore uid) async {
    final docSnap = await _collectionRef.doc(uid.value).get();

    return UserFirestore.fromDb(docSnap);
  }

  Future<void> setUser(UserIdFirestore uid, UserData userData) async {
    await _collectionRef.doc(uid.value).set(userData.toDbData());
  }

  Future<bool> doesUserExist(UserIdFirestore uid) async {
    final docSnap = await _collectionRef.doc(uid.value).get();

    return docSnap.exists;
  }
}

final userRepositoryProvider = Provider<UserRepositoryService>(
  (ref) => UserRepositoryService(
    firestore: ref.watch(firestoreProvider),
  ),
);
