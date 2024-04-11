import "package:flutter/foundation.dart";

/// A dataclass handling the error status of the create account page.
@immutable
class CreateAccountModel {
  final String? uniqueUsernameError;
  final String? pseudoError;
  final bool valid;

  /// Create a new instance of [CreateAccountModel].
  /// [uniqueUsernameError] and [pseudoError] are the error messages for
  /// the unique username and pseudo text fields respectively. If they are null,
  /// no error is displayed. [valid] is true if the form is valid. It is here to
  /// differentiate from the case where the fields have no error because they have
  /// not yet been validated from the case they have no errors because they are valid.
  const CreateAccountModel({
    required this.uniqueUsernameError,
    required this.pseudoError,
    required this.valid,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CreateAccountModel &&
        other.uniqueUsernameError == uniqueUsernameError &&
        other.pseudoError == pseudoError &&
        other.valid == valid;
  }

  @override
  int get hashCode {
    return Object.hash(
      uniqueUsernameError,
      pseudoError,
      valid,
    );
  }
}
