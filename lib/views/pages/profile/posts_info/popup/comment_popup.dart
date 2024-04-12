import "package:flutter/material.dart";

class CommentPopUp extends StatelessWidget {
  const CommentPopUp({
    super.key,
    required this.comment,
  });

  final String comment;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(comment),
      actions: <Widget>[
        IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.delete),
        ),
      ],
    );
  }
}
