import "dart:async";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/user/user_data.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/services/database/firestore_service.dart";

/// This repository service is responsible for managing the users in the database
class UserRepositoryService {
  final CollectionReference _collectionRef;

  UserRepositoryService({
    required FirebaseFirestore firestore,
  }) : _collectionRef = firestore.collection(UserFirestore.collectionName);

  /// This method will retrieve the user with id [uid] from the database
  Future<UserFirestore> getUser(UserIdFirestore uid) async {
    final docSnap = await _collectionRef.doc(uid.value).get();

    return UserFirestore.fromDb(docSnap);
  }

  /// This method will set the user with id [uid] to have the data [userData]
  /// If the user does not exist yet, it will be created
  Future<void> setUser(UserIdFirestore uid, UserData userData) async {
    await _collectionRef.doc(uid.value).set(userData.toDbData());
  }

  /// This method will check if the user with id [uid] exists in the database
  Future<bool> doesUserExist(UserIdFirestore uid) async {
    final docSnap = await _collectionRef.doc(uid.value).get();

    return docSnap.exists;
  }

  /// This method will check if the unique username [username] is already taken
  /// by some user
  Future<bool> isUsernameTaken(String username) async {
    final query = await _collectionRef
        .where(UserData.usernameField, isEqualTo: username)
        .get();
    return query.docs.isNotEmpty;
  }
}

final userRepositoryProvider = Provider<UserRepositoryService>(
  (ref) => UserRepositoryService(
    firestore: ref.watch(firestoreProvider),
  ),
);
