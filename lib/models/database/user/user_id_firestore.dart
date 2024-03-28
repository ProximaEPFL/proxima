import "package:flutter/foundation.dart";

/// The id are strong typed to avoid misuse
@immutable
class UserIdFirestore {
  final String value;

  const UserIdFirestore({required this.value});

  @override
  bool operator ==(Object other) {
    return other is UserIdFirestore && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}
