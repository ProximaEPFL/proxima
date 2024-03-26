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
      key: const Key("login_page"),
      body: Center(
        // padded centered column containing logo, text and login button
        child: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.indigo[100],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                child: ClipRRect(
                  // rounded logo image
                  borderRadius: BorderRadius.circular(28),
                  child: Image.asset("assets/images/proxima_logo.jpeg"),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Discover the world, one post at a time"),
              const SizedBox(height: 28),
              const LoginButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginButton extends HookConsumerWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: ElevatedButton(
        key: LoginPage.loginButtonKey,
        onPressed: () async {
          await ref.read(loginServiceProvider).signIn();
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login),
            SizedBox(width: 8),
            Text("Sign in with Google"),
          ],
        ),
      ),
    );
  }
}
