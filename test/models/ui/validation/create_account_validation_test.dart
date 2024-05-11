import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/ui/validation/create_account_validation.dart";

void main() {
  group("Create Account Model testing", () {
    test("hash overrides correctly", () {
      const createAccount = CreateAccountValidation(
        uniqueUsernameError: "uniqueUsernameError",
        pseudoError: "pseudoError",
        accountCreated: true,
      );

      final expectedHash = Object.hash(
        createAccount.uniqueUsernameError,
        createAccount.pseudoError,
        createAccount.accountCreated,
      );

      final actualHash = createAccount.hashCode;

      expect(actualHash, expectedHash);
    });

    test("equality overrides correctly", () {
      const createAccount = CreateAccountValidation(
        uniqueUsernameError: "uniqueUsernameError",
        pseudoError: "pseudoError",
        accountCreated: true,
      );

      const createAccountCopy = CreateAccountValidation(
        uniqueUsernameError: "uniqueUsernameError",
        pseudoError: "pseudoError",
        accountCreated: true,
      );

      expect(createAccount, createAccountCopy);
    });
  });
}
