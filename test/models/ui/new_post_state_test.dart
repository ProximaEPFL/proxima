import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/ui/new_post_validation.dart";

void main() {
  group("Create Account Model testing", () {
    test("hash overrides correctly", () {
      final newPostState = NewPostValidation(
        titleError: "titleError",
        descriptionError: "descriptionError",
        posted: true,
      );

      final expectedHash = Object.hash(
        newPostState.titleError,
        newPostState.descriptionError,
        newPostState.posted,
      );

      final actualHash = newPostState.hashCode;

      expect(actualHash, expectedHash);
    });

    test("equality overrides correctly", () {
      final newPostState = NewPostValidation(
        descriptionError: "descriptionError",
        titleError: "titleError",
        posted: true,
      );

      final newPostStateCopy = NewPostValidation(
        descriptionError: "descriptionError",
        titleError: "titleError",
        posted: true,
      );

      expect(newPostState, newPostStateCopy);
    });
  });
}
