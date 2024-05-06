import "package:flutter/material.dart";
import "package:proxima/models/database/user/user_data.dart";
import "package:proxima/views/navigation/leading_back_button/leading_back_button.dart";
import "package:proxima/views/pages/profile/components/logout_button.dart";
import "package:proxima/views/pages/profile/components/user_account.dart";

class ProfileAppBar extends AppBar {
  static const settingsKey = Key("settings");

  final UserData userData;

  ProfileAppBar({
    super.key,
    required this.userData,
  }) : super(
          leading: const LeadingBackButton(),
          title: UserAccount(
            userData: userData,
          ),
          actions: [
            const LogoutButton(),
            IconButton(
              key: settingsKey,
              icon: const Icon(Icons.settings),
              onPressed: () {
                //TODO: implement settings page
              },
            ),
          ],
        );
}
