import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/utils/ui/circular_value.dart";
import "package:proxima/viewmodels/login_view_model.dart";
import "package:proxima/viewmodels/profile_view_model.dart";
import "package:proxima/views/navigation/routes.dart";

class HomePage extends HookConsumerWidget {
  static const logoutButtonKey = Key("logout");
  static const profilePageButtonKey = Key("profile");

  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for authentication changes
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home page :)"),
        actions: [
          IconButton(
            key: profilePageButtonKey,
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, Routes.profile.name);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const UserProfile(),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              key: logoutButtonKey,
              onPressed: () {
                ref.read(loginServiceProvider).signOut();
              },
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}

class UserProfile extends HookConsumerWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CircularValue(
      value: ref.watch(profileProvider),
      builder: (context, data) {
        return Text("Welcome, ${data.user.email}");
      },
    );
  }
}
