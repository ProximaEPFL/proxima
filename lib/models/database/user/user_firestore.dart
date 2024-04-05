import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/foundation.dart";
import "package:proxima/models/database/user/user_data.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";

@immutable
class UserFirestore {
  // This is the collection where the users are stored
  static const collectionName = "users";

  /// The uid is not stored in a field because it already
  /// corresponds to the document id on firestore
  final UserIdFirestore uid;

  final UserData data;

  const UserFirestore({required this.uid, required this.data});

  /// This method will create an instance of [UserFirestore] from the
  /// document snapshot [docSnap] that comes from firestore
  factory UserFirestore.fromDb(DocumentSnapshot docSnap) {
    if (!docSnap.exists) {
      throw Exception("User document does not exist");
    }

    try {
      final data = docSnap.data() as Map<String, dynamic>;

      return UserFirestore(
        uid: UserIdFirestore(value: docSnap.id),
        data: UserData.fromDbData(data),
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
