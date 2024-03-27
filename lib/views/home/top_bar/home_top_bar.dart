import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/login_view_model.dart";
import "package:proxima/views/navigation/routes.dart";

/*
  This widget is the top bar of the home page
  It contains the timeline filters and the user profile picture
*/
class HomeTopBar extends HookConsumerWidget {
  static const logoutButtonKey = Key("logout");

  static const homeTopBarKey = Key("homeTopBar");
  static const profilePictureKey = Key("profilePicture");

  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //Temporary logout
    ref.listen(isUserLoggedInProvider, (_, isLoggedIn) {
      if (!isLoggedIn) {
        // Go to login page when the user is logged out
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.login.name,
          (route) => false,
        );
      }
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("Proxima", style: Theme.of(context).textTheme.headlineMedium),

        //Temporary logout button
        InkWell(
          key: logoutButtonKey,
          onTap: () => {ref.read(loginServiceProvider).signOut()},
          child: const Icon(Icons.logout),
        ),

        const CircleAvatar(
          key: profilePictureKey,
          child: Text("PR"),
        ),
      ],
    );
  }
}
