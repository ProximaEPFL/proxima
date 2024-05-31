import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/ui/validation/new_comment_validation.dart";

void main() {
  group("New Comment Model Testing", () {
    test("hash overrides correctly", () {
      // Define the expected result
      const newCommentState = NewCommentValidation(
        contentError: "contentError",
        posted: true,
      );

      final expectedHash = Object.hash(
        newCommentState.contentError,
        newCommentState.posted,
      );

      final actualHash = newCommentState.hashCode;

      expect(actualHash, expectedHash);
    });

    test("equality overrides correctly", () {
      // Define the expected result
      const newCommentState = NewCommentValidation(
        contentError: "commentError",
        posted: true,
      );

      const newCommentStateCopy = NewCommentValidation(
        contentError: "commentError",
        posted: true,
      );

      expect(newCommentState == newCommentStateCopy, true);
    });

    test("equality fails on different contentError", () {
      // Define the expected result
      const newCommentState = NewCommentValidation(
        contentError: "commentError",
        posted: true,
      );

      const newCommentStateCopy = NewCommentValidation(
        contentError: "commentError2",
        posted: true,
      );

      expect(newCommentState == newCommentStateCopy, false);
    });

    test("equality fails on different posted", () {
      // Define the expected result
      const newCommentState = NewCommentValidation(
        contentError: "commentError",
        posted: true,
      );

      const newCommentStateCopy = NewCommentValidation(
        contentError: "commentError",
        posted: false,
      );

      expect(newCommentState == newCommentStateCopy, false);
    });
  });
}
