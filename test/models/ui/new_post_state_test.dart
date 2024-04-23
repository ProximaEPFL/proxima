import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/ui/new_post_state.dart";

void main() {
  group("Create Account Model testing", () {
    test("hash overrides correctly", () {
      final newPostState = NewPostState(
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
      final newPostState = NewPostState(
        descriptionError: "descriptionError",
        titleError: "titleError",
        posted: true,
      );

      final newPostStateCopy = NewPostState(
        descriptionError: "descriptionError",
        titleError: "titleError",
        posted: true,
      );

      expect(newPostState, newPostStateCopy);
    });
  });
}
