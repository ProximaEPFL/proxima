import "package:flutter/material.dart";

class PostPopUp extends StatelessWidget {
  const PostPopUp({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(description),
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
