import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/login_view_model.dart";
import "package:proxima/views/navigation/routes.dart";

class LoginPage extends HookConsumerWidget {
  static const loginButtonKey = Key("login");

  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for authentication changes
    ref.listen(isUserLoggedInProvider, (_, loggedIn) {
      if (loggedIn) {
        // TODO: This should be Navigator.push instead, but we would have to make sure the user is logged out when coming  back here.
        // TODO: The route should be different according to whether the user exists or not.
        Navigator.pushReplacementNamed(context, Routes.createAccount.name);
      }
    });

    return Scaffold(
      body: Center(
        child: ElevatedButton(
          key: loginButtonKey,
          onPressed: () async {
            await ref.read(loginServiceProvider).signIn();
          },
          child: const Text("Login"),
        ),
      ),
    );
  }
}
