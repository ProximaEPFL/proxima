import "dart:async";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/foundation.dart";

/// The id are strong typed to avoid misuse
@immutable
class UserFirestoreId {
  final String value;

  const UserFirestoreId({required this.value});

  @override
  bool operator ==(Object other) {
    return other is UserFirestoreId && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

@immutable
class UserFirestore {
  /// The uid is not stored in a field because it already
  /// corresponds to the document id on firestore
  final UserFirestoreId uid;

  final UserFirestoreData data;

  const UserFirestore({required this.uid, required this.data});

  factory UserFirestore.fromDb(DocumentSnapshot docSnap) {
    if (!docSnap.exists) {
      throw Exception("User document does not exist");
    }

    try {
      final data = docSnap.data() as Map<String, dynamic>;

      return UserFirestore(
        uid: UserFirestoreId(value: docSnap.id),
        data: UserFirestoreData.fromDbData(data),
      );
    } catch (e) {
      if (e is TypeError) {
        throw FormatException("Cannot parse user document : ${e.toString()}");
      } else {
        rethrow;
      }
    }
  }

  @override
  bool operator ==(Object other) {
    return other is UserFirestore && other.uid == uid && other.data == data;
  }

  @override
  int get hashCode => Object.hash(uid, data);
}

@immutable
class UserFirestoreData {
  final String username;
  static const String usernameField = "username";

  final String displayName;
  static const String displayNameField = "displayName";

  final Timestamp joinTime;
  static const joinTimeField = "joinTime";

  const UserFirestoreData({
    required this.username,
    required this.displayName,
    required this.joinTime,
  });

  factory UserFirestoreData.fromDbData(Map<String, dynamic> data) {
    try {
      return UserFirestoreData(
        username: data[usernameField],
        displayName: data[displayNameField],
        joinTime: data[joinTimeField],
      );
    } catch (e) {
      if (e is TypeError) {
        throw FormatException(
          "Cannot parse user data document: ${e.toString()}",
        );
      } else {
        rethrow;
      }
    }
  }

  Map<String, dynamic> toDbData() {
    return {
      usernameField: username,
      displayNameField: displayName,
      joinTimeField: joinTime,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is UserFirestoreData &&
        other.username == username &&
        other.displayName == displayName &&
        other.joinTime == joinTime;
  }

  @override
  int get hashCode => Object.hash(username, displayName, joinTime);
}

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

    return getUser(UserFirestoreId(value: uid));
  }

  Future<UserFirestore> getUser(UserFirestoreId uid) async {
    final docSnap = await _collectionRef.doc(uid.value).get();

    return UserFirestore.fromDb(docSnap);
  }

  Future<void> setCurrentUser(UserFirestoreData userData) async {
    final uid = _getUid();

    await _collectionRef.doc(uid).set(userData.toDbData());
  }

  Future<bool> doesUserExists(UserFirestoreId uid) async {
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
