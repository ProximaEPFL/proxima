import "package:flutter/material.dart";

class CommentPopUp extends StatelessWidget {
  static const commentPopUpDescriptionKey = Key("commentPopUpDescription");
  static const commentPopUpDeleteButtonKey = Key("commentPopUpDeleteButton");

  const CommentPopUp({
    super.key,
    required this.comment,
  });

  final String comment;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 8.0,
              right: 8.0,
              bottom: 0.0,
              left: 8.0,
            ),
            child: Text(
              key: commentPopUpDescriptionKey,
              comment,
            ),
          ),
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
      actionsPadding: const EdgeInsets.only(
        right: 24.0,
        bottom: 12.0,
        top: 0.0,
        left: 24.0,
      ),
      actions: <Widget>[
        IconButton(
          key: commentPopUpDeleteButtonKey,
          onPressed: () {
            //TODO: Handle delete comment
            Navigator.pop(context);
          },
          icon: const Icon(Icons.delete),
        ),
      ],
    );
  }
}
