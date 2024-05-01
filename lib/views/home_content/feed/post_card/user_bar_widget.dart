import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:proxima/utils/ui/user_avatar.dart";

/// This widget is used to display the user bar in the post card.
/// It contains the user's profile picture and username.
class UserBarWidget extends StatelessWidget {
  static const displayNameTextKey = Key("displayNameText");
  static const timestampTextKey = Key("timestampText");

  const UserBarWidget({
    super.key,
    required this.posterUsername,
    required this.postTimestamp, //TODO: make optional for comments?
  });

  final String posterUsername;
  final Timestamp postTimestamp;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        UserAvatar(displayName: posterUsername, radius: 12),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            key: displayNameTextKey,
            posterUsername,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            key: timestampTextKey,
            postTimestamp.toDate().toString(),
          ),
        ),
      ],
    );
  }
}
