import "dart:async";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:proxima/models/database/user/user_data.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";

class UserRepositoryService {
  final CollectionReference _collectionRef;

  UserRepositoryService({
    required FirebaseFirestore firestore,
  }) : _collectionRef = firestore.collection(UserFirestore.collectionName);

  Future<UserFirestore> getUser(UserIdFirestore uid) async {
    final docSnap = await _collectionRef.doc(uid.value).get();

    return UserFirestore.fromDb(docSnap);
  }

  Future<void> setUser(UserIdFirestore uid, UserDataFirestore userData) async {
    await _collectionRef.doc(uid.value).set(userData.toDbData());
  }

  Future<bool> doesUserExist(UserIdFirestore uid) async {
    final docSnap = await _collectionRef.doc(uid.value).get();

    return docSnap.exists;
  }
}
