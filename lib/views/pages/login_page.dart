import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/login_viewmodel.dart";
import "package:proxima/views/navigation/routes.dart";

class LoginPage extends HookConsumerWidget {
  static const loginButtonKey = Key("login");

  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for authentication changes
    ref.listen(userProvider, (_, next) {
      final user = next.valueOrNull;
      if (user != null) {
        // Go to home page when the user is logged in
        Navigator.pushReplacementNamed(context, Routes.home.name);
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
