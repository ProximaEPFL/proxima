import "package:flutter/material.dart";
import "package:proxima/models/database/user/user_data.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/views/navigation/leading_back_button/leading_back_button.dart";
import "package:proxima/views/pages/profile/components/logout_button.dart";
import "package:proxima/views/pages/profile/components/user_account.dart";

// This widget displays the profile of a user as an app bar.
class ProfileAppBar extends AppBar {
  // The user data of the user to display
  final UserData userData;

  // The user id of the user to display
  final UserIdFirestore userID;

  ProfileAppBar({
    super.key,
    required this.userData,
    required this.userID,
  }) : super(
          leading: const LeadingBackButton(),
          title: UserAccount(
            userData: userData,
            userID: userID,
          ),
          actions: [
            const LogoutButton(),
          ],
        );
}
