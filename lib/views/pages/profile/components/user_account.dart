import "package:flutter/material.dart";
import "package:proxima/models/database/user/user_data.dart";
import "package:proxima/utils/ui/user_avatar/user_avatar.dart";

/// This widget display the user info in the profile page
class UserAccount extends StatelessWidget {
  static const userInfoKey = Key("userInfo");
  static const centauriPointsKey = Key("centauriPoints");

  const UserAccount({
    super.key,
    required this.userData,
  });

  final UserData userData;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleSmall;

    final displayName = Text(
      userData.displayName,
      style: textStyle,
      overflow: TextOverflow.fade,
    );

    final points = Text(
      key: centauriPointsKey,
      style: textStyle,
      "${userData.username} · ${userData.centauriPoints} Centauri",
    );

    final profilePicture =
        UserAvatar(displayName: userData.displayName, radius: 20);

    return Row(
      key: userInfoKey,
      children: [
        profilePicture,
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              displayName,
              points,
            ],
          ),
        ),
      ],
    );
  }
}
