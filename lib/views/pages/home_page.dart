import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/utils/ui/circular_value.dart";
import "package:proxima/viewmodels/login_viewmodel.dart";
import "package:proxima/viewmodels/profile_view_model.dart";
import "package:proxima/views/navigation/routes.dart";

class HomePage extends HookConsumerWidget {
  static const logoutButtonKey = Key("logout");

  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home page :)"),
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

                // Go to login page when the user is logged out
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.login.name,
                  (route) => false,
                );
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
