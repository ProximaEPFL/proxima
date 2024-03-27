import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/login_view_model.dart";

class LoginButton extends HookConsumerWidget {
  static const loginButtonKey = Key("login_button");

  static const _buttonText = "Sign in with Google";

  const LoginButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: ElevatedButton(
        key: loginButtonKey,
        onPressed: () async {
          await ref.read(loginServiceProvider).signIn();
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login),
            SizedBox(width: 8),
            Text(_buttonText),
          ],
        ),
      ),
    );
  }
}
