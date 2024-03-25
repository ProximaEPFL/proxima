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
        // Go to home page when the user is logged in
        Navigator.pushReplacementNamed(context, Routes.home.name);
      }
    });

    return Scaffold(
      body: Center(
        // padded centered column containing logo, text and login button
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child:
                  Image.asset("assets/images/proxima_logo.jpeg"),
              ),
              // logo
              const SizedBox(height: 16),
              // text
              const Text("Discover the world, one post at a time"),
              const SizedBox(height: 16),
              // login button
              ElevatedButton(
                key: loginButtonKey,
                onPressed: () async {
                  await ref.read(loginServiceProvider).signIn();
                },

                child: const Text("Sign in with Google"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
