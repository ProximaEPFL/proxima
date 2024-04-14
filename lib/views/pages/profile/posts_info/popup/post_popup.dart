import "package:flutter/material.dart";

class PostPopUp extends StatelessWidget {
  static const postPopUpTitleKey = Key("postPopUpTitle");
  static const postPopUpDescriptionKey = Key("postPopUpDescription");
  static const postPopUpDeleteButtonKey = Key("postPopUpDeleteButton");

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
      title: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          key: postPopUpTitleKey,
          maxLines: 1,
          title,
        ),
      ),
      content: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              key: postPopUpDescriptionKey,
              description,
            ),
          ),
        ),
      ),
      actions: <Widget>[
        IconButton(
          key: postPopUpDeleteButtonKey,
          onPressed: () {
            //TODO: Handle delete post
            Navigator.pop(context);
          },
          icon: const Icon(Icons.delete),
        ),
      ],
    );
  }
}
