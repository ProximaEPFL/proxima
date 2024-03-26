import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/login_view_model.dart";
import "package:proxima/views/navigation/routes.dart";

class LoginPage extends HookConsumerWidget {
  static const loginButtonKey = Key("login");
  static const logoKey = Key("logo");

  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = Theme.of(context);

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
          padding: const EdgeInsets.all(32.0),
          color: theme.colorScheme.background,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                flex:
                    2, // Adjust the flex factor to control how much space the logo takes
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  child: ClipRRect(
                    key: logoKey,
                    borderRadius: BorderRadius.circular(28.0),
                    child: Image.asset(
                      "assets/images/proxima_logo.jpeg",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const Flexible(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 8.0,
                    left: 24.0,
                    right: 24.0,
                  ),
                  child: Text(
                    "Discover the world,\n one post at a time",
                    textAlign: TextAlign
                        .center, // Ensure the text itself is centered if it spans multiple lines
                    // TODO: verify that the text style is correct after the theme is finalized
                  ),
                ),
              ),
              const Flexible(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 16.0,
                    bottom: 8.0,
                    left: 24.0,
                    right: 24.0,
                  ),
                  child: LoginButton(),
                ),
              ),
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
