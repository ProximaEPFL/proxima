import "package:flutter/material.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/models/ui/user_avatar_details.dart";
import "package:proxima/views/components/content/user_avatar/user_avatar.dart";
import "package:proxima/views/helpers/key_value_list_builder.dart";

/// A pop-up displaying a user's profile, i.e. their display name, username,
/// and Centauri points.
/// To make it appear, one can use:
/// showDialog(context: ..., builder: (BuildContext context) => UserProfilePopUp(...));
class UserProfilePopUp extends StatelessWidget {
  final String displayName;
  final String username;
  final UserIdFirestore userID;
  final int centauriPoints;

  const UserProfilePopUp({
    super.key,
    required this.displayName,
    required this.username,
    required this.userID,
    required this.centauriPoints,
  });

  @override
  Widget build(BuildContext context) {
    final listBuilder =
        KeyValueListBuilder(style: DefaultTextStyle.of(context).style)
            .addPair("Username", username)
            .addPair("Score", "$centauriPoints Centauri");

    return AlertDialog(
      title: Row(
        children: [
          UserAvatar(
            details: UserAvatarDetails(
              displayName: displayName,
              userID: userID,
              userCentauriPoints: centauriPoints,
            ),
            radius: 15,
          ),
          const SizedBox(width: 12),
          Text(
            displayName,
            style: Theme.of(context).textTheme.bodyLarge,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      content: listBuilder.generate(),
    );
  }
}
