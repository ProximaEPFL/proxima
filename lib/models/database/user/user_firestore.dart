import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/foundation.dart";
import "package:proxima/models/database/user/user_data.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";

@immutable
class UserFirestore {
  /// The uid is not stored in a field because it already
  /// corresponds to the document id on firestore
  final UserIdFirestore uid;

  final UserDataFirestore data;

  const UserFirestore({required this.uid, required this.data});

  factory UserFirestore.fromDb(DocumentSnapshot docSnap) {
    if (!docSnap.exists) {
      throw Exception("User document does not exist");
    }

    try {
      final data = docSnap.data() as Map<String, dynamic>;

      return UserFirestore(
        uid: UserIdFirestore(value: docSnap.id),
        data: UserDataFirestore.fromDbData(data),
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
