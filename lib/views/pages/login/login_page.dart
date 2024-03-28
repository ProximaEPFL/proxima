import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/login_view_model.dart";
import "package:proxima/views/navigation/routes.dart";
import "package:proxima/views/pages/login/login_button.dart";

class LoginPage extends HookConsumerWidget {
  static const loginPageKey = Key("login_page");
  static const logoKey = Key("login_logo");

  static const tagLineText = "Discover the world,\n one post at a time.";

  static const _logoAsset = "assets/images/proxima_logo.jpeg";

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

    final theme = Theme.of(context);

    final logoImage = Flexible(
      // Adjust the flex factor to control how much space the logo takes
      flex: 2,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: ClipRRect(
          key: logoKey,
          borderRadius: BorderRadius.circular(28),
          child: Image.asset(_logoAsset, fit: BoxFit.contain),
        ),
      ),
    );

    const tagLine = Flexible(
      child: Padding(
        padding: EdgeInsets.only(
          top: 8,
          left: 24,
          right: 24,
        ),
        // TODO: verify that the text style is correct after the theme is finalized
        child: Text(
          tagLineText,
          // Ensure the text itself is centered if it spans multiple lines
          textAlign: TextAlign.center,
        ),
      ),
    );

    const loginButton = Flexible(
      child: Padding(
        padding: EdgeInsets.only(
          top: 16,
          bottom: 8,
          left: 24,
          right: 24,
        ),
        child: LoginButton(),
      ),
    );

    return Scaffold(
      key: loginPageKey,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          color: theme.colorScheme.background,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              logoImage,
              tagLine,
              loginButton,
            ],
          ),
        ),
      ),
    );
  }
}
