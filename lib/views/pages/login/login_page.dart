import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/services/database/user_repository_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";
import "package:proxima/views/navigation/routes.dart";
import "package:proxima/views/pages/login/login_button.dart";

class LoginPage extends ConsumerWidget {
  static const loginPageKey = Key("login_page");
  static const logoKey = Key("login_logo");

  static const tagLineText = "Discover the world,\n one post at a time.";

  static const _logoAsset = "assets/images/proxima_white.png";

  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRepository = ref.watch(userRepositoryServiceProvider);

    ref.listen(loggedInUserIdProvider, (_, user) async {
      if (user != null) {
        final exists = await userRepository.doesUserExist(user);

        //Ensure that the page is still mounted before navigating
        if (!context.mounted) return;

        if (exists) {
          Navigator.pushReplacementNamed(context, Routes.home.name);
        } else {
          Navigator.pushReplacementNamed(context, Routes.createAccount.name);
        }
      }
    });

    final theme = Theme.of(context);

    final logoBorder = BorderRadius.circular(28);
    final logoImage = Flexible(
      // Adjust the flex factor to control how much space the logo takes
      flex: 2,
      child: Container(
        padding: const EdgeInsets.all(28),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: logoBorder,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 10,
                blurRadius: 10,
              ),
            ],
          ),
          child: ClipRRect(
            key: logoKey,
            borderRadius: logoBorder,
            child: Image.asset(_logoAsset, fit: BoxFit.contain),
          ),
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
