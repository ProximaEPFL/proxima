import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/login_view_model.dart";
import "package:proxima/views/navigation/routes.dart";

class CreateAccountPage extends HookConsumerWidget {
  static const logoutButtonKey = Key("logout");
  static const confirmButtonKey = Key("confirm");

  static const uniqueUsernameFieldKey = Key("uniqueUsername");
  static const pseudoFieldKey = Key("pseudo");

  const CreateAccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    navigateToLoginPageOnLogout(context, ref);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: logoutButtonKey,
          onPressed: () {
            ref.read(loginServiceProvider).signOut();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text("Create your account"),
      ),
      body: const Padding(
        padding: EdgeInsets.only(left: 50, right: 50, top: 50, bottom: 50),
        child: Center(child: _CreateAccountPageContent()),
      ),
    );
  }
}

class _CreateAccountPageContent extends HookConsumerWidget {
  const _CreateAccountPageContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Flexible(flex: 20, child: Container()),
        const TextField(
          key: CreateAccountPage.uniqueUsernameFieldKey,
          decoration: InputDecoration(
            labelText: "Unique username",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        const TextField(
          key: CreateAccountPage.pseudoFieldKey,
          decoration: InputDecoration(
            labelText: "Pseudo",
            border: OutlineInputBorder(),
          ),
        ),
        Flexible(flex: 50, child: Container()),
        ElevatedButton(
          key: CreateAccountPage.confirmButtonKey,
          onPressed: () {
            // TODO: Also store this to the database
            Navigator.pushReplacementNamed(context, Routes.home.name);
          },
          child: const Text("Confirm"),
        ),
      ],
    );
  }
}
