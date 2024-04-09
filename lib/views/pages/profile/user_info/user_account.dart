import "package:flutter/material.dart";

/// This widget display the user info in the profile page
class UserAccount extends StatelessWidget {
  static const userInfoKey = Key("user Info");
  static const centauriPointsKey = Key("centauri points");

  const UserAccount({
    super.key,
    required this.userEmail,
  });

  final String? userEmail;

  @override
  Widget build(BuildContext context) {
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
                userEmail ?? "averylongemailjusttocheckthatitfades",
                style: Theme.of(context).textTheme.titleSmall,
                overflow: TextOverflow.fade,
              ),
              Text(
                //TODO: get the user points from the viewmodel
                "User Profile · 1000 Points ",
                style: Theme.of(context).textTheme.titleSmall,
                key: centauriPointsKey,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
