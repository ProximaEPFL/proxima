import "package:flutter/foundation.dart";

/// The id are strong typed to avoid misuse
@immutable
class PostIdFirestore {
  final String value;

  const PostIdFirestore({required this.value});

  @override
  bool operator ==(Object other) {
    return other is PostIdFirestore && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}
