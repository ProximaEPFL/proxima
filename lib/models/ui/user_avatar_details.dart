import "package:flutter/foundation.dart";
import "package:proxima/models/database/user/user_data.dart";

/// A class that stores data for a user avatar UI.
@immutable
class UserAvatarDetails {
  final String displayName;
  final int? userCentauriPoints;

  /// Creates a [UserAvatarDetails] object.
  /// [displayName] is the user's display name, of which
  /// the first letter is displayed on the avatar.
  /// [userCentauriPoints] is the user's centauri points,
  /// which is used to color the avatar background.
  const UserAvatarDetails({
    required this.displayName,
    required this.userCentauriPoints,
  });

  /// Converts a [UserData] object, [userData], to a [UserAvatarDetails] object.
  factory UserAvatarDetails.fromUserData(UserData userData) {
    return UserAvatarDetails(
      displayName: userData.displayName,
      userCentauriPoints: userData.centauriPoints,
    );
  }

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
