import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/validation/create_account_validation.dart";
import "package:proxima/viewmodels/create_account_view_model.dart";
import "package:proxima/views/components/layout/scrollable_if_too_high.dart";
import "package:proxima/views/pages/create_account/create_account_page.dart";

class CreateAccountForm extends HookConsumerWidget {
  static const uniqueUsernameFieldKey = Key("uniqueUsername");
  static const pseudoFieldKey = Key("pseudo");

  final CreateAccountValidation validation;

  const CreateAccountForm({
    super.key,
    required this.validation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pseudoController = useTextEditingController();
    final uniqueUsernameController = useTextEditingController();

    final userNameField = TextField(
      key: CreateAccountForm.uniqueUsernameFieldKey,
      decoration: InputDecoration(
        labelText: "Unique username",
        errorText: validation.uniqueUsernameError,
        helperText: "", // for the error text not to change the widget height
        border: const OutlineInputBorder(),
      ),
      controller: uniqueUsernameController,
    );

    final pseudoField = TextField(
      key: CreateAccountForm.pseudoFieldKey,
      decoration: InputDecoration(
        labelText: "Pseudo",
        errorText: validation.pseudoError,
        helperText: "", // for the error text not to change the widget height
        border: const OutlineInputBorder(),
      ),
      controller: pseudoController,
    );

    final submitButton = ElevatedButton(
      key: CreateAccountPage.confirmButtonKey,
      onPressed: () {
        ref.read(createAccountViewModelProvider.notifier).createAccountIfValid(
              pseudoController.text,
              uniqueUsernameController.text,
            );
      },
      child: const Text("Confirm"),
    );

    return ScrollableIfTooHigh(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(flex: 20, child: Container()),
          const SizedBox(height: 20),
          userNameField,
          const SizedBox(height: 20),
          pseudoField,
          Flexible(flex: 50, child: Container()),
          const SizedBox(height: 50),
          submitButton,
          Flexible(flex: 20, child: Container()),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
