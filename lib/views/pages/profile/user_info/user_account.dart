import "package:flutter/material.dart";

/// This widget display the user info in the profile page
class UserAccount extends StatelessWidget {
  const UserAccount({
    super.key,
    required this.theme,
    required this.userEmail,
  });

  final ThemeData theme;
  final String? userEmail;

  @override
  Widget build(BuildContext context) {
    return Row(
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
                style: theme.textTheme.titleSmall,
                overflow: TextOverflow.fade,
              ),
              Text(
                "User Profile",
                style: theme.textTheme.titleSmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
