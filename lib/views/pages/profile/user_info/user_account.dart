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
    ThemeData themeData = Theme.of(context);
    TextStyle? textStyle = themeData.textTheme.titleSmall;
    final userName = userData.username;
    final userDisplayName = userData.displayName;
    final centauriPoints = userData.centauriPoints;

    return Row(
      key: userInfoKey,
      children: [
        const CircleAvatar(
          radius: 20,
          //TODO: get the image from the viewmodel
          //backgroundImage: AssetImage("assets/images/user.png" ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //TODO: get the profile info from the viewmodel
              Text(
                userDisplayName,
                style: textStyle,
                overflow: TextOverflow.fade,
              ),
              Text(
                //TODO: get the user points from the viewmodel
                "$userName · $centauriPoints Centauri",
                style: textStyle,
                key: centauriPointsKey,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
