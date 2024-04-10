import "dart:async";

import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/create_account_errors.dart";
import "package:proxima/services/database/user_repository_service.dart";

class CreateAccountViewModel extends AsyncNotifier<CreateAccountErrors?> {
  @override
  Future<CreateAccountErrors?> build() async {
    return null;
  }

  /// Validate a [pseudo] by returning an error message if it is invalid. Returns null if it is valid.
  /// A pseudo is invalid if:
  /// - It is empty
  String? validatePseudo(String pseudo) {
    if (pseudo.isEmpty) {
      return "The pseudo cannot be blank.";
    }
    return null;
  }

  /// Validate a [uniqueUsername] by returning an error message if it is invalid. Returns null if it is valid.
  /// A unique username is invalid if:
  /// - It is empty
  /// - It is already taken by another user in the database
  Future<String?> validateUniqueUsername(String uniqueUsername) async {
    if (uniqueUsername.isEmpty) {
      return "The username cannot be blank.";
    }

    if (await ref
        .read(userRepositoryProvider)
        .isUsernameTaken(uniqueUsername)) {
      return "This username is already taken.";
    }
    return null;
  }

  /// Validate a [pseudo] and a [uniqueUsername] and update the state with the errors.
  /// See [validatePseudo] and [validateUniqueUsername] for the validation rules.
  Future<void> validate(String pseudo, String uniqueUsername) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final pseudoError = validatePseudo(pseudo);
      final uniqueUsernameError = await validateUniqueUsername(uniqueUsername);
      return CreateAccountErrors(
        pseudoError: pseudoError,
        uniqueUsernameError: uniqueUsernameError,
        valid: pseudoError == null && uniqueUsernameError == null,
      );
    });
  }
}

/// The provider for the [CreateAccountViewModel]
final createAccountErrorsProvider =
    AsyncNotifierProvider<CreateAccountViewModel, CreateAccountErrors?>(
  () => CreateAccountViewModel(),
);
