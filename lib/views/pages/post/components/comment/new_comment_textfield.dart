import "package:flutter/material.dart";
import "package:proxima/models/ui/new_comment_validation.dart";

/// The text field in which the user can write a new comment.
class NewCommentTextField extends StatelessWidget {
  static const _textFieldHintAddComment = "Add a comment";
  static const addCommentTextFieldKey = Key("addCommentTextField");

  const NewCommentTextField({
    super.key,
    required this.commentContentController,
    required this.newCommentState,
  });

  final TextEditingController commentContentController;
  final NewCommentValidation newCommentState;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextField(
        key: addCommentTextFieldKey,
        minLines: 1,
        maxLines: 5,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(8),
          border: const OutlineInputBorder(),
          hintText: _textFieldHintAddComment,
          errorText: newCommentState.contentError,
        ),
        controller: commentContentController,
      ),
    );
  }
}
