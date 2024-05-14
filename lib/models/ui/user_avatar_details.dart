import "package:flutter/foundation.dart";

@immutable
class UserAvatarDetails {
  final String displayName;
  final int? userCentauriPoints;

  const UserAvatarDetails({
    required this.displayName,
    required this.userCentauriPoints,
  });

  @override
  bool operator ==(Object other) {
    return other is UserAvatarDetails &&
        other.displayName == displayName &&
        other.userCentauriPoints == userCentauriPoints;
  }

  @override
  int get hashCode {
    return Object.hash(
      displayName,
      userCentauriPoints,
    );
  }
}
