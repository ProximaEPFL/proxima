import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/services/authentication/auth_login_service.dart";

class LogoutButton extends ConsumerWidget {
  static const logoutButtonKey = Key("logoutButton");

  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      key: logoutButtonKey,
      onPressed: ref.read(authLoginServiceProvider).signOut,
      icon: const Icon(Icons.logout),
    );
  }
}
