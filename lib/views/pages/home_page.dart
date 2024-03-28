import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/utils/ui/circular_value.dart";
import "package:proxima/viewmodels/login_view_model.dart";
import "package:proxima/viewmodels/profile_view_model.dart";

class HomePage extends HookConsumerWidget {
  static const logoutButtonKey = Key("logout");
  static const newPostKey = Key("New Post");

  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    navigateToLoginPageOnLogout(context, ref);

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
              },
              child: const Text("Logout"),
            ),
          ],
        ),
      ),

      // TODO(new post) remove on merge with home page, make sure to merge the test keys
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: IconButton(
            key: newPostKey,
            onPressed: () {
              Navigator.pushNamed(context, Routes.newPost.name);
            },
            icon: const Icon(Icons.add),
          ),
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
