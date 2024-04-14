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
            padding: const EdgeInsets.all(8.0),
            child: Text(
              key: commentPopUpDescriptionKey,
              comment,
            ),
          ),
        ),
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
