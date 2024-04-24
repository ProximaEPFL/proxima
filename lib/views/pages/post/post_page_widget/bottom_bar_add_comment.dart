import "package:flutter/material.dart";

class BottomBarAddComment extends StatelessWidget {
  static const commentUserAvatarKey = Key("commentUserAvatar");
  static const addCommentTextFieldKey = Key("addCommentTextField");
  static const postCommentButtonKey = Key("postCommentButton");

  final String currentDisplayName;

  const BottomBarAddComment({
    super.key,
    required this.currentDisplayName,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment
          .start, // Align items to the start of the cross axis
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: CircleAvatar(
            key: commentUserAvatarKey,
            radius: 22,
            child: Text(currentDisplayName.substring(0, 1)),
          ),
        ),
        const Expanded(
          child: TextField(
            key: addCommentTextFieldKey,
            minLines: 1,
            maxLines: 5,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(8),
              border: OutlineInputBorder(),
              hintText: "Add a comment",
            ),
          ),
        ),
        Align(
          alignment: Alignment
              .center, // Keeps the IconButton centered in the cross axis
          child: IconButton(
            key: postCommentButtonKey,
            icon: const Icon(Icons.send),
            onPressed: () {
              //TODO: handle add comment
              FocusManager.instance.primaryFocus?.unfocus();
            },
          ),
        ),
      ],
    );
  }
}
