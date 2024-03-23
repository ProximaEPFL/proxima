import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";

class UserFirestore {
  /// The uid is not stored in a field because it already
  /// corresponds to the document id on firestore
  final String uid;

  final String username;
  static const String usernameField = "username";

  final Timestamp joinTime;
  static const joinTimeField = "joinTime";

  UserFirestore({
    required this.uid,
    required this.username,
    required this.joinTime,
  });

  factory UserFirestore.fromDb(DocumentSnapshot docSnap) {
    if (!docSnap.exists) {
      throw Exception("User document does not exist");
    }

    final data = docSnap.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("User document data is null");
    }

    return UserFirestore(
      uid: docSnap.id,
      username: data[usernameField],
      joinTime: data[joinTimeField],
    );
  }

  Map<String, dynamic> toDb() {
    return {
      usernameField: username,
      joinTimeField: joinTime,
    };
  }
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
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }

    return getUser(uid);
  }

  Future<UserFirestore> getUser(String uid) async {
    final docSnap = await _collectionRef.doc(uid).get();

    return UserFirestore.fromDb(docSnap);
  }

  Future<void> setUser(UserFirestore user) async {
    if (user.uid.isEmpty) {
      throw const FormatException("Cannot set a user with empty uid");
    }

    await _collectionRef.doc(user.uid).set(user.toDb());
  }
}
