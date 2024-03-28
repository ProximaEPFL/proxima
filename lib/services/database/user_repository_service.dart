import "dart:async";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:proxima/models/database/user/user_data.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";

class UserRepository {
  final FirebaseAuth _firebaseAuth;

  static const collectionName = "users";
  final CollectionReference _collectionRef;

  UserRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth firebaseAuth,
  })  : _firebaseAuth = firebaseAuth,
        _collectionRef = firestore.collection(collectionName);

  Future<UserFirestore> getCurrentUser() async {
    final uid = _getUid();

    return getUser(UserIdFirestore(value: uid));
  }

  Future<UserFirestore> getUser(UserIdFirestore uid) async {
    final docSnap = await _collectionRef.doc(uid.value).get();

    return UserFirestore.fromDb(docSnap);
  }

  Future<void> setCurrentUser(UserDataFirestore userData) async {
    final uid = _getUid();

    await _collectionRef.doc(uid).set(userData.toDbData());
  }

  Future<bool> doesUserExist(UserIdFirestore uid) async {
    final docSnap = await _collectionRef.doc(uid.value).get();

    return docSnap.exists;
  }

  String _getUid() {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }

    return uid;
  }
}
