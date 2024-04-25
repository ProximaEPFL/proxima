import "package:flutter/material.dart";
import "package:proxima/models/database/user/user_data.dart";

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

    const profilePicture = CircleAvatar(
      radius: 20,
      //TODO: get the image from the viewmodel
      //backgroundImage: AssetImage("assets/images/user.png" ),
    );

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
