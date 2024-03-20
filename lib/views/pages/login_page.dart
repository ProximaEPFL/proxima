import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/login_viewmodel.dart";
import "package:proxima/views/navigation/routes.dart";

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for authentication changes
    ref.listen(authProvider, (_, auth) {
      if (auth.valueOrNull != null) {
        // Go to home page when the user is logged in
        Navigator.pushReplacementNamed(context, Routes.home.name);
      }
    });

    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: ref.read(userProvider.notifier).signInRequest,
          child: const Text("Login"),
        ),
      ),
    );
  }
}
