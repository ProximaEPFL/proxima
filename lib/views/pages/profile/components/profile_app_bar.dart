import "package:flutter/material.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/views/navigation/leading_back_button/leading_back_button.dart";
import "package:proxima/views/pages/profile/components/logout_button.dart";
import "package:proxima/views/pages/profile/components/user_account.dart";

// This widget displays the profile of a user as an app bar.
class ProfileAppBar extends AppBar {
  // The user to display
  final UserFirestore user;

  ProfileAppBar({
    super.key,
    required this.user,
  }) : super(
          leading: const LeadingBackButton(),
          title: UserAccount(user: user),
          actions: [
            const LogoutButton(),
          ],
        );
}
