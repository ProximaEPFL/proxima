import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/services/authentication/auth_login_service.dart";
import "package:proxima/viewmodels/create_account_view_model.dart";
import "package:proxima/viewmodels/login_view_model.dart";
import "package:proxima/views/components/async/circular_value.dart";
import "package:proxima/views/components/layout/scrollable_if_too_high.dart";
import "package:proxima/views/navigation/leading_back_button/leading_back_button.dart";
import "package:proxima/views/navigation/routes.dart";

class CreateAccountPage extends HookConsumerWidget {
  static const confirmButtonKey = Key("confirm");

  static const uniqueUsernameFieldKey = Key("uniqueUsername");
  static const pseudoFieldKey = Key("pseudo");

  const CreateAccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    navigateToLoginPageOnLogout(context, ref);

    ref.listen(createAccountViewModelProvider, (previous, error) {
      if (error.valueOrNull?.accountCreated == true) {
        Navigator.pushReplacementNamed(context, Routes.home.name);
      }
    });

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        ref.read(authLoginServiceProvider).signOut();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const LeadingBackButton(),
          title: const Text("Create your account"),
        ),
        body: const Padding(
          padding: EdgeInsets.only(left: 50, right: 50),
          child: Center(child: _CreateAccountPageContent()),
        ),
      ),
    );
  }
}

class _CreateAccountPageContent extends HookConsumerWidget {
  const _CreateAccountPageContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncErrors = ref.watch(createAccountViewModelProvider);
    final pseudoController = useTextEditingController();
    final uniqueUsernameController = useTextEditingController();

    return CircularValue(
      value: asyncErrors,
      builder: (context, errors) {
        return ScrollableIfTooHigh(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(flex: 20, child: Container()),
              const SizedBox(height: 20),
              TextField(
                key: CreateAccountPage.uniqueUsernameFieldKey,
                decoration: InputDecoration(
                  labelText: "Unique username",
                  errorText: errors.uniqueUsernameError,
                  helperText:
                      "", // for the error text not to change the widget height
                  border: const OutlineInputBorder(),
                ),
                controller: uniqueUsernameController,
              ),
              const SizedBox(height: 20),
              TextField(
                key: CreateAccountPage.pseudoFieldKey,
                decoration: InputDecoration(
                  labelText: "Pseudo",
                  errorText: errors.pseudoError,
                  helperText:
                      "", // for the error text not to change the widget height
                  border: const OutlineInputBorder(),
                ),
                controller: pseudoController,
              ),
              Flexible(flex: 50, child: Container()),
              const SizedBox(height: 50),
              ElevatedButton(
                key: CreateAccountPage.confirmButtonKey,
                onPressed: () {
                  ref
                      .read(createAccountViewModelProvider.notifier)
                      .createAccountIfValid(
                        pseudoController.text,
                        uniqueUsernameController.text,
                      );
                },
                child: const Text("Confirm"),
              ),
              Flexible(flex: 20, child: Container()),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
