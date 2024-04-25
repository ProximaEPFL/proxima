import "package:flutter/material.dart";
import "package:proxima/utils/ui/user_avatar.dart";

/// This widget is used to display the user bar in the post card.
/// It contains the user's profile picture and username.
class UserBarWidget extends StatelessWidget {
  const UserBarWidget({
    super.key,
    required this.posterUsername,
  });

  final String posterUsername;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        UserAvatar(displayName: posterUsername, radius: 12),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(posterUsername),
        ),
      ],
    );
  }
}
