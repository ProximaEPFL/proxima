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
            padding: const EdgeInsets.only(
              top: 8.0,
              right: 8.0,
              bottom: 0.0,
              left: 8.0,
            ),
            child: Text(
              key: postPopUpDescriptionKey,
              description,
            ),
          ),
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 0.0),
      actionsPadding: const EdgeInsets.only(
        right: 24.0,
        bottom: 12.0,
        top: 0.0,
        left: 24.0,
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
