import "package:flutter/foundation.dart";
import "package:proxima/models/database/user/user_data.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";

/// A class that stores data for a user avatar UI.
@immutable
class UserAvatarDetails {
  final String displayName;
  final UserIdFirestore? userID;
  final int? userCentauriPoints;

  /// Creates a [UserAvatarDetails] object.
  /// [displayName] is the user's display name, of which
  /// the first letter is displayed on the avatar.
  /// [userID] is the user's ID. It can null
  /// to allow creating a user avatar without a user and
  /// useful for loading states.
  /// [userCentauriPoints] is the user's centauri points,
  /// which is used to color the avatar background.
  const UserAvatarDetails({
    required this.displayName,
    required this.userID,
    required this.userCentauriPoints,
  });

  /// Converts a [UserData] object, [userData], to a [UserAvatarDetails] object.
  factory UserAvatarDetails.fromUserData(
    UserData userData,
    UserIdFirestore userID,
  ) {
    return UserAvatarDetails(
      displayName: userData.displayName,
      userID: userID,
      userCentauriPoints: userData.centauriPoints,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserAvatarDetails &&
        other.displayName == displayName &&
        other.userID == userID &&
        other.userCentauriPoints == userCentauriPoints;
  }

  @override
  int get hashCode {
    return Object.hash(
      displayName,
      userID,
      userCentauriPoints,
    );
  }
}
