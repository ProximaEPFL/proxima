import "package:flutter/foundation.dart";
import "package:proxima/models/database/user/user_firestore.dart";

/// A class that stores data for a user avatar UI.
@immutable
class UserAvatarDetails {
  final String displayName;
  final int? centauriPoints;

  /// Creates a [UserAvatarDetails] object.
  /// [displayName] is the user's display name, of which
  /// the first letter is displayed on the avatar.
  /// [centauriPoints] is the user's centauri points.
  /// The [centauriPoints] parameter can be null, which is useful for loading states.
  const UserAvatarDetails({
    required this.displayName,
    required this.centauriPoints,
  });

  /// Converts a [UserFirestore] object, [user], to a [UserAvatarDetails] object.
  factory UserAvatarDetails.fromUser(
    UserFirestore user,
  ) {
    return UserAvatarDetails(
      displayName: user.data.displayName,
      centauriPoints: user.data.centauriPoints,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserAvatarDetails &&
        other.displayName == displayName &&
        other.centauriPoints == centauriPoints;
  }

  @override
  int get hashCode {
    return Object.hash(
      displayName,
      centauriPoints,
    );
  }
}
