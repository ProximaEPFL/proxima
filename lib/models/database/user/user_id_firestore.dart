import "package:flutter/foundation.dart";
import "package:proxima/models/database/firestore/id_firestore.dart";

/// The id are strong typed to avoid misuse
@immutable
class UserIdFirestore extends IdFirestore {
  @override
  final String value;

  const UserIdFirestore({required this.value});

  @override
  bool operator ==(Object other) {
    return other is UserIdFirestore && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}
