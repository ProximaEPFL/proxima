import "dart:async";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/user/user_data.dart";
import "package:proxima/models/ui/create_account_model.dart";
import "package:proxima/services/database/user_repository_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";

class CreateAccountViewModel extends AsyncNotifier<CreateAccountModel> {
  @override
  Future<CreateAccountModel> build() async {
    return const CreateAccountModel();
  }

  /// Validate a generic [value], either a pseudo or a username,
  /// by returning an error message if it is invalid".
  /// Returns null if it is valid.
  /// A value is invalid if:
  /// - It is empty
  /// - It contains spaces
  /// - It is less than 3 characters long
  /// - It is more than 20 characters long
  /// - It contains special characters
  String? _validateString(String value) {
    if (value.isEmpty) {
      return "Cannot be blank.";
    }

    if (value.contains(" ")) {
      return "Cannot contain spaces.";
    }

    if (value.length < 3) {
      return "Too short.";
    }

    if (value.length > 20) {
      return "Too long.";
    }

    // This regular expression is intentionally too restrictive (for instance,
    // the {3,20} is already checked above). Its purpose is too make sure that
    // the value is whitelisted; not that it is not blacklisted.
    if (!RegExp(r"^\w{3,20}$").hasMatch(value)) {
      return "Invalid characters.";
    }

    return null;
  }

  /// Validate a [pseudo] by returning an error message if it is invalid. Returns null if it is valid.
  /// A pseudo is invalid if:
  /// - It is invalid according to [_validateString]
  String? validatePseudo(String pseudo) {
    return _validateString(pseudo);
  }

  /// Validate a [uniqueUsername] by returning an error message if it is invalid. Returns null if it is valid.
  /// A unique username is invalid if:
  /// - It is invalid according to [_validateString]
  /// - It is already taken by another user in the database
  Future<String?> validateUniqueUsername(String uniqueUsername) async {
    final error = _validateString(uniqueUsername);
    if (error != null) {
      return error;
    }

    if (await ref
        .read(userRepositoryProvider)
        .isUsernameTaken(uniqueUsername)) {
      return "This username is already taken.";
    }
    return null;
  }

  /// Validate a [pseudo] and a [uniqueUsername] and update the state with the potential errors.
  /// If it happens that both are valid, the account is created.
  /// See [validatePseudo] and [validateUniqueUsername] for the validation rules.
  Future<void> createAccountIfValid(
    String pseudo,
    String uniqueUsername,
  ) async {
    state = const AsyncValue.loading();
    AsyncValue<CreateAccountModel> newState = await AsyncValue.guard(() async {
      final pseudoError = validatePseudo(pseudo);
      final uniqueUsernameError = await validateUniqueUsername(uniqueUsername);
      return CreateAccountModel(
        pseudoError: pseudoError,
        uniqueUsernameError: uniqueUsernameError,
      );
    });

    // Create the account before applying the new state
    if (newState.valueOrNull?.noError == true) {
      final uid = ref.read(uidProvider);
      if (uid == null) {
        // The user is no longer logged in, so they will anyway be sent to the login page
        state = const AsyncValue.data(CreateAccountModel());
        return;
      }

      final userData = UserData(
        username: uniqueUsername,
        displayName: pseudo,
        joinTime: Timestamp.now(),
      );
      await ref.read(userRepositoryProvider).setUser(uid, userData);
      // Here the [newState.valueOrNull] cannot be null because [newState.valueOrNull?.noError]
      // is checked to be true above.
      newState =
          AsyncValue.data(newState.valueOrNull!.withAccountCreated(true));
    }

    state = newState;
  }
}

/// The provider for the [CreateAccountViewModel]
final createAccountErrorsProvider =
    AsyncNotifierProvider<CreateAccountViewModel, CreateAccountModel>(
  () => CreateAccountViewModel(),
);
