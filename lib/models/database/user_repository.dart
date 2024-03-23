import "package:cloud_firestore/cloud_firestore.dart";

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

  factory UserFirestore.fromDb(DocumentSnapshot<Map<String, dynamic>> docSnap) {
    final data = docSnap.data();
    if (data == null) {
      throw StateError("User document data cannot be null");
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
