import "package:flutter/foundation.dart";

/// A dataclass handling the error status of the create account page.
@immutable
class CreateAccountModel {
  final String? uniqueUsernameError;
  final String? pseudoError;
  final bool accountCreated;

  /// Create a new instance of [CreateAccountModel].
  /// [uniqueUsernameError] and [pseudoError] are the error messages for
  /// the unique username and pseudo text fields respectively. If they are null,
  /// no error is displayed. [accountCreated] is true if the form is valid. It is here to
  /// differentiate from the case where the fields have no error because they have
  /// not yet been validated from the case they have no errors because they are valid.
  const CreateAccountModel({
    this.uniqueUsernameError,
    this.pseudoError,
    this.accountCreated = false,
  });

  /// Returns true if the form for account creation is valid, i.e. there is no error.
  bool get noError => uniqueUsernameError == null && pseudoError == null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CreateAccountModel &&
        other.uniqueUsernameError == uniqueUsernameError &&
        other.pseudoError == pseudoError &&
        other.accountCreated == accountCreated;
  }

  @override
  int get hashCode {
    return Object.hash(
      uniqueUsernameError,
      pseudoError,
      accountCreated,
    );
  }
}
