import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/utils/ui/circular_value.dart";
import "package:proxima/utils/ui/scrollable_if_too_high.dart";
import "package:proxima/viewmodels/create_accout_view_model.dart";
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

    ref.listen(createAccountErrorsProvider, (previous, error) {
      if (error.valueOrNull?.valid == true) {
        Navigator.pushReplacementNamed(context, Routes.home.name);
      }
    });

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
        padding: EdgeInsets.only(left: 50, right: 50),
        child: Center(child: _CreateAccountPageContent()),
      ),
    );
  }
}

class _CreateAccountPageContent extends HookConsumerWidget {
  const _CreateAccountPageContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncErrors = ref.watch(createAccountErrorsProvider);
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
                  errorText: errors?.uniqueUsernameError,
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
                  errorText: errors?.pseudoError,
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
                  ref.read(createAccountErrorsProvider.notifier).validate(
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
