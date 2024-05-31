import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/services/authentication/auth_login_service.dart";
import "package:proxima/viewmodels/create_account_view_model.dart";
import "package:proxima/viewmodels/login_view_model.dart";
import "package:proxima/views/components/async/circular_value.dart";
import "package:proxima/views/helpers/types/result.dart";
import "package:proxima/views/navigation/leading_back_button/leading_back_button.dart";
import "package:proxima/views/navigation/routes.dart";
import "package:proxima/views/pages/create_account/create_account_form.dart";

class CreateAccountPage extends ConsumerWidget {
  static const confirmButtonKey = Key("confirm");

  const CreateAccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncErrors =
        ref.watch(createAccountViewModelProvider.future).mapRes();

    navigateToLoginPageOnLogout(context, ref);

    ref.listen(createAccountViewModelProvider, (previous, error) {
      if (error.valueOrNull?.accountCreated == true) {
        Navigator.pushReplacementNamed(context, Routes.home.name);
      }
    });

    final form = Center(
      child: CircularValue(
        future: asyncErrors,
        builder: (context, errors) => CreateAccountForm(
          validation: errors,
        ),
      ),
    );

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
        body: Padding(
          padding: const EdgeInsets.only(left: 50, right: 50),
          child: form,
        ),
      ),
    );
  }
}
