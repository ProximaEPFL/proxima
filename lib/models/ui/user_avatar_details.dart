import "package:flutter/foundation.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";

/// A class that stores data for a user avatar UI.
@immutable
class UserAvatarDetails {
  final String displayName;
  final UserIdFirestore? userID;

  /// Creates a [UserAvatarDetails] object.
  /// [displayName] is the user's display name, of which
  /// the first letter is displayed on the avatar.
  /// [userID] is the user's ID. Can be null
  /// to allow creating a user avatar without a user which
  /// is useful for loading states.
  const UserAvatarDetails({
    required this.displayName,
    required this.userID,
  });

  /// Converts a [UserFirestore] object, [user], to a [UserAvatarDetails] object.
  factory UserAvatarDetails.fromUser(
    UserFirestore user,
  ) {
    return UserAvatarDetails(
      displayName: user.data.displayName,
      userID: user.uid,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserAvatarDetails &&
        other.displayName == displayName &&
        other.userID == userID;
  }

  @override
  int get hashCode {
    return Object.hash(
      displayName,
      userID,
    );
  }
}
